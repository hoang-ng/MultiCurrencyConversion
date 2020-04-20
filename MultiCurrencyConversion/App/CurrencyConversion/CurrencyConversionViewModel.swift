//
//  CurrencyConversionVIewModel.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CurrencyConversionViewModel {
    
    let currencyList = [Currency.USD, Currency.SGD, Currency.EUR, Currency.MYR]
    
    // MARK: - Input
    let selectFromCurrency = PublishSubject<Void>()
    let selectToCurrency = PublishSubject<Void>()
    let convertCurrency = PublishSubject<String>()
    let viewHistory = PublishSubject<Void>()
    let fromAmount = BehaviorRelay<String?>(value: nil)
    let toAmount = BehaviorRelay<String?>(value: nil)
    let addTransaction = PublishSubject<String>()

    // MARK: - Output
    let isLoading = BehaviorRelay<Bool>(value: false)
    let currentBalance = BehaviorRelay<WalletBalance?>(value: nil)
    let selectedFromCurrency = BehaviorRelay<Currency>(value: Currency.SGD)
    let selectedToCurrency = BehaviorRelay<Currency>(value: Currency.USD)
    let didSelectFromCurrency = PublishSubject<Currency>()
    let didSelectToCurrency = PublishSubject<Currency>()
    let showConvertConfirmationAlert = PublishSubject<String>()
    let showConvertFailAlert = PublishSubject<String>()
    let currentExchangeRate = BehaviorRelay<ExchangeRate?>(value: nil)
    let convertedFromAmount = BehaviorRelay<String?>(value: nil)
    let convertedToAmount = BehaviorRelay<String?>(value: nil)
    
    let transactionStore: TransactionStore!
    let exchangeRateAPI: ExchangeRateAPIProtocol!
    
    private let disposeBag = DisposeBag()
    
    init(exchangeRateAPI: ExchangeRateAPIProtocol, transactionStore: TransactionStore) {
        self.exchangeRateAPI = exchangeRateAPI
        self.transactionStore = transactionStore
        
        bindingSelectCurrency()
        bindingAmount()
        bindingShowConvertConfirmationAlert()
    }
    
    func getWalletBalance() {
        self.transactionStore.getWalletBalance(completion: { [weak self] result in
            let walletBalance = try! result.get()
            self?.currentBalance.accept(walletBalance)
            self?.selectedFromCurrency.accept(walletBalance.currency)
            self?.didSelectFromCurrency.onNext(walletBalance.currency)
        })
    }
    
    func getExchangeRate(baseCurrency: Currency) -> Observable<ExchangeRate> {
        isLoading.accept(true)
        return Observable.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.exchangeRateAPI.getExchangeRate(baseCurrency: baseCurrency) { result in
                self.isLoading.accept(false)
                do {
                    let exchangeRate = try result.get()
                    self.currentExchangeRate.accept(exchangeRate)
                    observer.onNext(exchangeRate)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func updateWalletBalance(exchangeRate: ExchangeRate) {
        guard var currentBalance = self.currentBalance.value, let rate = exchangeRate.rates[currentBalance.currency] else { return }
        currentBalance.amount = currentBalance.amount / Double(rate)
        currentBalance.currency = exchangeRate.baseCurrency
        self.transactionStore.updateWalletBalance(walletBalance: currentBalance) { result in
            switch result {
            case .success():
                self.currentBalance.accept(currentBalance)
                self.selectedFromCurrency.accept(currentBalance.currency)
            case .failure(_):
                break
            }
        }
    }
    
    func getExchangeRate(exchangeRate: ExchangeRate) -> String {
        let fromCurrency = exchangeRate.baseCurrency.rawValue
        let toCurrency = self.selectedToCurrency.value.rawValue
        
        if let rate = exchangeRate.rates[self.selectedToCurrency.value] {
            return fromCurrency + " 1 to " + toCurrency + String(format: " %.2f", rate)
        }
        return ""
    }
    
    func bindingSelectCurrency() {
        didSelectFromCurrency
            .flatMap({ [weak self] currency -> Observable<ExchangeRate> in
                guard let `self` = self else { return Observable.empty() }
                return self.getExchangeRate(baseCurrency: currency)
            })
            .subscribe(onNext: {[weak self] exchangeRate in
                guard let `self` = self else { return }
                self.updateWalletBalance(exchangeRate: exchangeRate)
                self.currentExchangeRate.accept(exchangeRate)
                if let fromAmount = self.fromAmount.value {
                    self.fromAmount.accept(fromAmount)
                }
            })
            .disposed(by: disposeBag)
        
        didSelectToCurrency
            .flatMap({ [weak self] currency -> Observable<ExchangeRate> in
                guard let `self` = self else { return Observable.empty() }
                self.selectedToCurrency.accept(currency)
                return self.getExchangeRate(baseCurrency: self.selectedFromCurrency.value)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self, let toAmount = self.toAmount.value else { return }
                self.toAmount.accept(toAmount)
            })
            .disposed(by: disposeBag)
    }
    
    func bindingAmount() {
        fromAmount.subscribe(onNext: { [weak self] value in
            guard let `self` = self, let currentRate = self.currentExchangeRate.value else { return }
            if let value = value, let fromAmount = Double(value), let rate = currentRate.rates[self.selectedToCurrency.value] {
                let result = fromAmount * Double(rate)
                self.convertedToAmount.accept(String(format: "%.2f", result))
            } else {
                self.convertedToAmount.accept(nil)
            }
        })
        .disposed(by: disposeBag)
        
        toAmount.subscribe(onNext: { [weak self] value in
            guard let `self` = self, let currentRate = self.currentExchangeRate.value else { return }
            if let value = value, let toAmount = Double(value), let rate = currentRate.rates[self.selectedToCurrency.value] {
                let result = toAmount / Double(rate)
                self.convertedFromAmount.accept(String(format: "%.2f", result))
            } else {
                self.convertedFromAmount.accept(nil)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func bindingShowConvertConfirmationAlert() {
        convertCurrency.subscribe(onNext: { [weak self] amount in
            guard let `self` = self, let currentRate = self.currentExchangeRate.value, let currentBalance = self.currentBalance.value else { return }
            guard let fromAmount = Double(amount) else { return }
            if let rate = currentRate.rates[self.selectedToCurrency.value], fromAmount < currentBalance.amount {
                let result = fromAmount * Double(rate)
                let message = "Are you sure you want to convert " + self.selectedFromCurrency.value.rawValue + String(format: "%.2f", fromAmount) + " to " + self.selectedToCurrency.value.rawValue + String(format: "%.2f", result)
                self.showConvertConfirmationAlert.onNext(message)
            } else {
                self.showConvertFailAlert.onNext("Your wallet does not have enough money!")
            }
        }).disposed(by: disposeBag)
        
        addTransaction.subscribe(onNext: { [weak self] amount in
            guard let `self` = self, let currentRate = self.currentExchangeRate.value, let currentBalance = self.currentBalance.value else { return }
            if let fromAmount = Double(amount), let rate = currentRate.rates[self.selectedToCurrency.value], fromAmount < currentBalance.amount {
                let result = fromAmount * Double(rate)
                
                var newBalance = currentBalance
                newBalance.amount -= result
                self.transactionStore.updateWalletBalance(walletBalance: newBalance) { _ in
                    self.currentBalance.accept(newBalance)
                }
                self.transactionStore.insertTransaction(txn: Transaction(txnID: UUID(), date: Date(), fromCurrency: self.selectedFromCurrency.value.rawValue, toCurrency: self.selectedToCurrency.value.rawValue, fromAmount: fromAmount, rate: Float(rate))) { _ in
                    self.viewHistory.onNext(())
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func getFromCurrencyList() -> [Currency] {
        let currencyList = [Currency.USD, Currency.SGD, Currency.EUR, Currency.MYR]
        return currencyList.filter { $0 != selectedToCurrency.value }
    }
    
    func getToCurrencyList() -> [Currency] {
        let currencyList = [Currency.USD, Currency.SGD, Currency.EUR, Currency.MYR]
        return currencyList.filter { $0 != selectedFromCurrency.value }
    }
}
