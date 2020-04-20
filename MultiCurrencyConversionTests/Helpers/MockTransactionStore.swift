//
//  MockTransactionStore.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
@testable import MultiCurrencyConversion

class MockTransactionStore: TransactionStore {
    func insertTransaction(txn: Transaction, completion: (Result<Void, Error>) -> ()) {
    }
    
    func insertTransactions(txns: [Transaction], completion: (Result<Void, Error>) -> ()) {
    }
    
    var transactionsCompletions = [(Result<[Transaction], Error>) -> ()]()
    func getTransactions(completion: @escaping (Result<[Transaction], Error>) -> ()) {
        transactionsCompletions.append(completion)
    }
    
    func completeWithTransaction(transactions: [Transaction]) {
        transactionsCompletions[0](.success(transactions))
    }
    
    var walletBalanceCompletions = [(Result<WalletBalance, Error>) -> ()]()
    func getWalletBalance(completion: @escaping (Result<WalletBalance, Error>) -> ()) {
        walletBalanceCompletions.append(completion)
    }
    
    func completeWithWalletBalance(balance: WalletBalance) {
        walletBalanceCompletions[0](.success(balance))
    }
    
    var updateWalletBalanceCompletions = [(Result<Void, Error>) -> ()]()
    func updateWalletBalance(walletBalance: WalletBalance, completion: @escaping (Result<Void, Error>) -> ()) {
        updateWalletBalanceCompletions.append(completion)
    }
    
    func updateWalletBalanceComplete() {
        updateWalletBalanceCompletions[0](.success(()))
    }
}
