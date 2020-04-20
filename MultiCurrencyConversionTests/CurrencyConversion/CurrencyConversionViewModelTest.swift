//
//  CurrencyConversionViewModelTest.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import XCTest
import RxSwift
@testable import MultiCurrencyConversion

class CurrencyConversionViewModelTest: XCTestCase {

    func test_getWalletBalance() {
        let (sut, store, _) = makeSUT()
        
        sut.getWalletBalance()
        XCTAssertEqual(store.walletBalanceCompletions.count, 1)
        
        sut.getWalletBalance()
        XCTAssertEqual(store.walletBalanceCompletions.count, 2)
    }
    
    func test_getWalletBalance_shouldHaveBalance() {
        let (sut, store, _) = makeSUT()
        
        sut.getWalletBalance()
        let balance = WalletBalance(amount: 5500, currency: .MYR)
        store.completeWithWalletBalance(balance: balance)
        
        XCTAssertEqual(sut.currentBalance.value?.amount, balance.amount)
        XCTAssertEqual(sut.selectedFromCurrency.value, .MYR)
    }
    
    func test_getExchangeRate_showLoading() {
        let (sut, _, _) = makeSUT()
        _ = sut.getExchangeRate(baseCurrency: .SGD)
        
        XCTAssertEqual(sut.isLoading.value, true)
    }
    
    func test_getExchangeRate_hideLoadingWhenComplete() {
        let disposeBag = DisposeBag()
        let (sut, _, api) = makeSUT()
        
        let exp = expectation(description: "wait for completions")
        sut.getExchangeRate(baseCurrency: .SGD).subscribe(onNext: { exchangeRate in
            exp.fulfill()
        })
        .disposed(by: disposeBag)
        
        api.completeWithExchangeRate(exchangeRate: ExchangeRate(rates: [.SGD: 1, .USD: 1.42], baseCurrency: .SGD))
        
        XCTAssertEqual(sut.isLoading.value, false)
        wait(for: [exp], timeout: 5)
    }
    
    func test_getExchangeRate_shouldHaveExchangeRate() {
        let disposeBag = DisposeBag()
        let (sut, _, api) = makeSUT()
        
        let exp = expectation(description: "wait for completions")
        var recievedExchangeRate: ExchangeRate?
        sut.getExchangeRate(baseCurrency: .SGD).subscribe(onNext: { exchangeRate in
            recievedExchangeRate = exchangeRate
            exp.fulfill()
        })
        .disposed(by: disposeBag)
        
        let expectedExchangeRate = ExchangeRate(rates: [.SGD: 1, .USD: 1.42], baseCurrency: .SGD)
        api.completeWithExchangeRate(exchangeRate: expectedExchangeRate)
        
        XCTAssertEqual(recievedExchangeRate, expectedExchangeRate)
        XCTAssertEqual(sut.currentExchangeRate.value, expectedExchangeRate)
        wait(for: [exp], timeout: 5)
    }
    
    func test_updateWalletBalance() {
        let (sut, store, _) = makeSUT()
        sut.currentBalance.accept(WalletBalance(amount: 500, currency: .SGD))
        sut.updateWalletBalance(exchangeRate: ExchangeRate(rates: [.SGD: 1.5], baseCurrency: .USD))
     
        store.updateWalletBalanceComplete()
        
        XCTAssertEqual(store.updateWalletBalanceCompletions.count, 1)
        XCTAssertEqual(sut.currentBalance.value, WalletBalance(amount: 500 / 1.5, currency: .USD))
        XCTAssertEqual(sut.selectedFromCurrency.value, .USD)
    }
    
    func test_getFromCurrencyList() {
        let (sut, _, _) = makeSUT()
        sut.selectedToCurrency.accept(.EUR)
        
        let currencyList = sut.getFromCurrencyList()
        XCTAssertEqual(currencyList, [Currency.USD, Currency.SGD, Currency.MYR])
    }
    
    func test_getToCurrencyList() {
        let (sut, _, _) = makeSUT()
        sut.selectedFromCurrency.accept(.EUR)
        
        let currencyList = sut.getToCurrencyList()
        XCTAssertEqual(currencyList, [Currency.USD, Currency.SGD, Currency.MYR])
    }

    //MARK: - Helper
    func makeSUT() -> (CurrencyConversionViewModel, MockTransactionStore, MockExchangeRateAPI) {
        let store = MockTransactionStore()
        let api = MockExchangeRateAPI()
        let sut = CurrencyConversionViewModel(exchangeRateAPI: api, transactionStore: store)
        
        return (sut, store, api)
    }
}

class MockExchangeRateAPI: ExchangeRateAPIProtocol {
    
    var completions = [(Result<ExchangeRate, Error>) -> ()]()
    func getExchangeRate(baseCurrency: Currency, completion: @escaping (Result<ExchangeRate, Error>) -> ()) {
        completions.append(completion)
    }
    
    func completeWithExchangeRate(exchangeRate: ExchangeRate) {
        completions[0](.success(exchangeRate))
    }
}
