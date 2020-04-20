//
//  TransactionHistoryViewControllerTest.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import XCTest
@testable import MultiCurrencyConversion

class TransactionHistoryViewControllerTest: XCTestCase {

    func test_init_doNotGetTransactions() {
        let (_, viewModel, _) = makeSUT()
        XCTAssertTrue(!viewModel.isGetTransaction)
    }
    
    func test_viewDidLoad_shouldGetTransactions() {
        let (sut, viewModel, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(viewModel.isGetTransaction)
    }
    
    func test_getTransactionsCompletion_rendersSuccessfullyUI() {
        let (sut, _, store) = makeSUT()
        sut.loadViewIfNeeded()
        let txn1 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 100, rate: 0.70)
        let txn2 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 120, rate: 0.70)
        let expectedTransactions = [txn1, txn2]
        
        store.completeWithTransaction(transactions: expectedTransactions)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), expectedTransactions.count)
        
        let cell1 = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TransactionCell
        let cell2 = sut.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TransactionCell
        
        XCTAssertEqual(cell1.transactionIDLabel.text, "TX" + txn1.txnID.uuidString.suffix(6))
        XCTAssertEqual(cell1.transactionDetailLabel.text, txn1.detail())
        XCTAssertEqual(cell1.rateLabel.text, txn1.rateString())
        
        XCTAssertEqual(cell2.transactionIDLabel.text, "TX" + txn2.txnID.uuidString.suffix(6))
        XCTAssertEqual(cell2.transactionDetailLabel.text, txn2.detail())
        XCTAssertEqual(cell2.rateLabel.text, txn2.rateString())
    }
    
    
    // MARK: - Helper
    func makeSUT() -> (sut: TransactionHistoryViewController, viewModel: MockTransactionHistoryViewModel, store: MockTransactionStore) {
        let sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionHistoryViewController") as! TransactionHistoryViewController
        let store = MockTransactionStore()
        let viewModel = MockTransactionHistoryViewModel(transactionStore: store)
        sut.viewModel = viewModel
        return (sut, viewModel, store)
    }
    
}
