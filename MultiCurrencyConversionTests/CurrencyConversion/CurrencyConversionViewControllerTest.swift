//
//  CurrencyConversionViewControllerTest.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import XCTest
@testable import MultiCurrencyConversion

class CurrencyConversionViewControllerTest: XCTestCase {

    func test_init() {
        let (_, _, store, api) = makeSUT()
        XCTAssertEqual(store.walletBalanceCompletions.count, 0)
        XCTAssertEqual(api.completions.count, 0)
    }
    
    func test_viewDidLoad() {
        let (sut, _, store, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(store.walletBalanceCompletions.count, 1)
    }
    
    func test_viewDidLoad_loadCurrentBalance() {
        let (sut, _, store, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        store.completeWithWalletBalance(balance: WalletBalance(amount: 150, currency: .USD))
        
        XCTAssertEqual(sut.balanceLabel.text, "150.00")
        XCTAssertEqual(sut.fromCurrencyButton.titleLabel?.text, "USD")
    }
    
    func test_didSelectFromCurrency_getExchangeRate() {
        let (sut, viewModel, _, api) = makeSUT()
        sut.loadViewIfNeeded()
        viewModel.didSelectFromCurrency.onNext(.EUR)
        
        XCTAssertEqual(api.completions.count, 1)
    }
    
    func test_didSelectToCurrency_getExchangeRate() {
        let (sut, viewModel, _, api) = makeSUT()
        sut.loadViewIfNeeded()
        viewModel.didSelectToCurrency.onNext(.EUR)
        
        XCTAssertEqual(api.completions.count, 1)
    }
    
    func test_getExchangeRate() {
        let (sut, viewModel, _, api) = makeSUT()
        viewModel.selectedFromCurrency.accept(.SGD)
        viewModel.selectedToCurrency.accept(.USD)
        sut.loadViewIfNeeded()
        viewModel.didSelectFromCurrency.onNext(.EUR)
        
        api.completeWithExchangeRate(exchangeRate: ExchangeRate(rates: [.SGD: 0.5], baseCurrency: .EUR))
        
        XCTAssertEqual(viewModel.currentExchangeRate.value, ExchangeRate(rates: [.SGD: 0.5], baseCurrency: .EUR))
    }
    
    func test_selectFromCurrency_dismissKeyboard() {
        let (sut, _, _, _) = makeSUT()
        sut.loadViewIfNeeded()
        sut.fromAmountTextField.becomeFirstResponder()
        sut.fromCurrencyButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(sut.fromAmountTextField.isFirstResponder, false)
    }
    
    func test_selectToCurrency_dismissKeyboard() {
        let (sut, _, _, _) = makeSUT()
        sut.loadViewIfNeeded()
        sut.toAmountTextField.becomeFirstResponder()
        sut.toCurrencyButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(sut.toAmountTextField.isFirstResponder, false)
    }

    //MARK: - Helpers
    func makeSUT() -> (sut: CurrencyConversionViewController, vm: CurrencyConversionViewModel, store: MockTransactionStore, api: MockExchangeRateAPI) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrencyConversionViewController") as! CurrencyConversionViewController
        let store = MockTransactionStore()
        let api = MockExchangeRateAPI()
        let vm = CurrencyConversionViewModel(exchangeRateAPI: api, transactionStore: store)
        viewController.viewModel = vm
        
        return (viewController, vm, store, api)
    }
}
