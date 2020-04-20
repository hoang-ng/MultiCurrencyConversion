//
//  CurrencyConversionCoordinator.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import RxSwift
import Foundation

class CurrencyConversionCoordinator: ReactiveCoordinator<Void> {
    
    let rootViewController: UIViewController
    let currencyList = [Currency.USD, Currency.SGD, Currency.EUR, Currency.MYR]
    
    private let transactionStore: TransactionStore
    private let exchangeRateAPI: ExchangeRateAPIProtocol
    
    init(rootViewController: UIViewController, transactionStore: TransactionStore, exchangeRateAPI: ExchangeRateAPIProtocol) {
        self.rootViewController = rootViewController
        self.transactionStore = transactionStore
        self.exchangeRateAPI = exchangeRateAPI
    }
    
    override func start() -> Observable<Void> {
        let viewController = rootViewController as! CurrencyConversionViewController
        let viewModel = CurrencyConversionViewModel(exchangeRateAPI: exchangeRateAPI, transactionStore: transactionStore)
        viewController.viewModel = viewModel
        
        viewModel.selectFromCurrency
            .flatMap { [weak self] _ -> Observable<Currency?> in
                guard let `self` = self else { return .empty() }
                let currencies = viewModel.getFromCurrencyList()
                return self.coordinateToSelectCurrency(currencies: currencies)
        }
        .filter { $0 != nil }
        .map { $0! }
        .bind(to: viewModel.didSelectFromCurrency)
        .disposed(by: disposeBag)
        
        viewModel.selectToCurrency
            .flatMap { [weak self] _ -> Observable<Currency?> in
                guard let `self` = self else { return .empty() }
                let currencies = viewModel.getToCurrencyList()
                return self.coordinateToSelectCurrency(currencies: currencies)
        }
        .filter { $0 != nil }
        .map { $0! }
        .bind(to: viewModel.didSelectToCurrency)
        .disposed(by: disposeBag)
        
        viewModel.viewHistory.flatMap { [weak self] _ -> Observable<Void> in
            guard let `self` = self else { return .empty() }
            return self.coordinateToTransactionHistory()
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    //MARK: - Coordination
    
    private func coordinateToSelectCurrency(currencies: [Currency]) -> Observable<Currency?> {
        let selectCurrencyCoordinator = SelectCurrencyCoordinator(rootViewController: rootViewController, currencies: currencies)
        return coordinate(to: selectCurrencyCoordinator)
            .map { result in
                switch result {
                case .currency(let currency): return currency
                case .cancel: return nil
            }
        }
    }
    
    private func coordinateToTransactionHistory() -> Observable<Void> {
        let transactionHistoryCoordinator = TransactionHistoryCoordinator(rootViewController: rootViewController, transactionStore: transactionStore)
        return coordinate(to: transactionHistoryCoordinator)
            .map { _ in () }
    }
}
