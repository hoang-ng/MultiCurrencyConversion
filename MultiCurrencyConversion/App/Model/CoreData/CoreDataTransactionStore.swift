//
//  CoreDataCurrencyStore.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import CoreData

class CoreDataTransactionStore: TransactionStore {
    
    public static let storeURL = NSPersistentContainer.defaultDirectoryURL()
                                    .appendingPathComponent("transaction-store.sqlite")
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "MultiCurrencyConversion", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    func insertTransaction(txn: Transaction, completion: (Result<Void, Error>) -> ()) {
        completion(Result {
            let managed = ManagedTransaction(context: context)
            managed.id = txn.txnID
            managed.date = txn.date
            managed.fromAmount = txn.fromAmount
            managed.toAmount = txn.toAmount
            managed.fromCurrency = txn.fromCurrency
            managed.toCurrency = txn.toCurrency
            managed.rate = txn.rate
            try context.save()
        })
    }
    
    func insertTransactions(txns: [Transaction], completion: (Result<Void, Error>) -> ()) {
        completion(Result {
            for txn in txns {
                let managed = ManagedTransaction(context: context)
                managed.id = txn.txnID
                managed.date = txn.date
                managed.fromAmount = txn.fromAmount
                managed.toAmount = txn.toAmount
                managed.fromCurrency = txn.fromCurrency
                managed.toCurrency = txn.toCurrency
                managed.rate = txn.rate
            }
            try context.save()
        })
    }
    
    func getTransactions(completion: @escaping (Result<[Transaction], Error>) -> ()) {
        perform { context in
            completion(Result {
                let request = NSFetchRequest<ManagedTransaction>(entityName: ManagedTransaction.entity().name!)
                request.returnsObjectsAsFaults = false
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                return try context.fetch(request).map({ managedTransaction -> Transaction in
                    return Transaction(txnID: managedTransaction.id!, date: managedTransaction.date!, fromCurrency: managedTransaction.fromCurrency!, toCurrency: managedTransaction.toCurrency!, fromAmount: managedTransaction.fromAmount, rate: managedTransaction.rate)
                })
            })
        }
    }
    
    func getWalletBalance(completion: @escaping (Result<WalletBalance, Error>) -> ()) {
        perform { context in
            let request = NSFetchRequest<ManagedBalance>(entityName: ManagedBalance.entity().name!)
            request.returnsObjectsAsFaults = false
            do {
                if let managedBalance = try context.fetch(request).first {
                    completion(.success(WalletBalance(amount: managedBalance.balance, currency: Currency(rawValue: managedBalance.currency!) ?? .SGD)))
                } else {
                    let newManagedBalance = CoreDataTransactionStore.makeDefaultBalance(context: context)
                    try context.save()
                    completion(.success(WalletBalance(amount: newManagedBalance.balance, currency: Currency(rawValue: newManagedBalance.currency!) ?? .SGD)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateWalletBalance(walletBalance: WalletBalance, completion: @escaping (Result<Void, Error>) -> ()) {
        perform { context in
            let request = NSFetchRequest<ManagedBalance>(entityName: ManagedBalance.entity().name!)
            request.returnsObjectsAsFaults = false
            do {
                let managedBalance = try context.fetch(request).first ?? ManagedBalance(context: context)
                managedBalance.balance = walletBalance.amount
                managedBalance.currency = walletBalance.currency.rawValue
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private static func makeDefaultBalance(context: NSManagedObjectContext) -> ManagedBalance {
        let newManagedBalance = ManagedBalance(context: context)
        newManagedBalance.balance = 15000
        newManagedBalance.currency = "SGD"
        return newManagedBalance
    }
}
