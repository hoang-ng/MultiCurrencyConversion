//
//  TransactionHistoryViewModel.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import XCTest
@testable import MultiCurrencyConversion

class TransactionHistoryViewModelTest: XCTestCase {

    func test_init() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.transactionsCompletions.count, 0)
    }
    
    func test_getTransactions() {
        let (sut, store) = makeSUT()
        sut.getTransaction()
        
        XCTAssertEqual(store.transactionsCompletions.count, 1)
    }
    
    func test_getTransactions_shouldHaveTransactions() {
        let txn1 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 100, rate: 0.70)
        let txn2 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 120, rate: 0.70)
        let expectedTransactions = [txn1, txn2]
        let (sut, store) = makeSUT()
        sut.getTransaction()
        
        store.completeWithTransaction(transactions: expectedTransactions)
        
        XCTAssertEqual(sut.transactions.value, expectedTransactions)
    }
    
    //MARK: - Helper
    func makeSUT() -> (viewModel: TransactionHistoryViewModel, store: MockTransactionStore) {
        let store = MockTransactionStore()
        let sut = TransactionHistoryViewModel(transactionStore: store)
        return (sut, store)
    }

}
