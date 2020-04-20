//
//  CoreDataCurrencyStoreTests.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import XCTest
@testable import MultiCurrencyConversion

class CoreDataCurrencyStoreTests: XCTestCase {

    func test_getWalletBalance_shouldHaveDefaultBalance() {
        let sut = makeSUT()
        
        let expectedResult = WalletBalance(amount: 15000, currency: .SGD)
        let exp = expectation(description: "Waiting for completion")
        
        sut.getWalletBalance { result in
            switch result {
            case let .success(receivedTxn):
                XCTAssertEqual(receivedTxn, expectedResult)
            case let .failure(error):
                XCTFail("Expect get current balance to succeed, got \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }
    
    func test_updateWalletBalance_shouldUpdateCurrentBalance() {
        let sut = makeSUT()
        
        let expectedResult = WalletBalance(amount: 15500, currency: .USD)
        
        let exp1 = expectation(description: "Waiting for completion")
        sut.updateWalletBalance(walletBalance: expectedResult) { receivedResult in
            switch receivedResult {
            case let .failure(error):
                XCTFail("Expect update balance to succeed, got \(error)")
            default:
                break
            }
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Waiting for completion")
        sut.getWalletBalance { receivedResult in
            switch receivedResult {
            case let .success(receivedTxn):
                XCTAssertEqual(receivedTxn, expectedResult)
            case let .failure(error):
                XCTFail("Expect get current balance to succeed, got \(error)")
            }
            exp2.fulfill()
        }
        wait(for: [exp1, exp2], timeout: 5)
    }
    
    func test_insertTransaction_shouldInsertTranctionSuccessfully() {
        let sut = makeSUT()
        let trx1 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 100, rate: 0.7)
        let exp = expectation(description: "Waiting for completion")
        sut.insertTransaction(txn: trx1) { receivedResult in
            switch receivedResult {
            case .success():
                break
            case let .failure(error):
                XCTFail("Expected insert transaction to succeed, got \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_getTransactions_shouldGetTransactionsSuccessfully() {
        let sut = makeSUT()
        let trx1 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 100, rate: 0.7)
        
        let exp1 = expectation(description: "Waiting for insert completion")
        sut.insertTransaction(txn: trx1) { receivedResult in
            switch receivedResult {
            case .success():
                break
            case let .failure(error):
                XCTFail("Expected insert transaction to succeed, got \(error)")
            }
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Waiting for get transaction completion")
        sut.getTransactions { receivedResult in
            switch receivedResult {
            case let .success(receivedTransactions):
                XCTAssertEqual(receivedTransactions, [trx1])
            case let .failure(error):
                XCTFail("Expected get transaction to succeed, got \(error)")
            }
            exp2.fulfill()
        }
        
        wait(for: [exp1, exp2], timeout: 5.0)
    }
    
    func test_getMultipleTransactions_shouldGetTransactionsSuccessfully() {
        let sut = makeSUT()
        let trx1 = Transaction(txnID: UUID(), date: Date(), fromCurrency: Currency.SGD.rawValue, toCurrency: Currency.USD.rawValue, fromAmount: 100, rate: 0.7)
        
        let exp1 = expectation(description: "Waiting for insert completion")
        sut.insertTransactions(txns: [trx1]) { receivedResult in
            switch receivedResult {
            case .success():
                break
            case let .failure(error):
                XCTFail("Expected insert transaction to succeed, got \(error)")
            }
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Waiting for get transaction completion")
        sut.getTransactions { receivedResult in
            switch receivedResult {
            case let .success(receivedTransactions):
                XCTAssertEqual(receivedTransactions, [trx1])
            case let .failure(error):
                XCTFail("Expected get transaction to succeed, got \(error)")
            }
            exp2.fulfill()
        }
        
        wait(for: [exp1, exp2], timeout: 5.0)
    }
    
    // - MARK: Helpers
    
    private func makeSUT() -> TransactionStore {
        let storeBundle = Bundle(for: CoreDataTransactionStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataTransactionStore(storeURL: storeURL, bundle: storeBundle)
        return sut
    }

}
