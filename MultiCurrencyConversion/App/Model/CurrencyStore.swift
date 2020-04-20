//
//  CurrencyStore.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/14/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation

protocol TransactionStore {
    func insertTransaction(txn: Transaction, completion: (Result<Void, Error>) -> ())
    func insertTransactions(txns: [Transaction], completion: (Result<Void, Error>) -> ())
    func getTransactions(completion: @escaping (Result<[Transaction], Error>) -> ())
    func getWalletBalance(completion: @escaping (Result<WalletBalance, Error>) -> ())
    func updateWalletBalance(walletBalance: WalletBalance, completion: @escaping (Result<Void, Error>) -> ())
}
