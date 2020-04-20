//
//  TransactionHistoryViewModel.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TransactionHistoryViewModel {
    
    let transactionStore: TransactionStore!
    var transactions = BehaviorRelay<[Transaction]>(value: [])
    
    init(transactionStore: TransactionStore) {
        self.transactionStore = transactionStore
    }
    
    func getTransaction() {
        transactionStore.getTransactions { [weak self] result in
            guard let `self` = self else { return }
            do {
                let transactions = try result.get()
                self.transactions.accept(transactions)
            } catch {
            }
        }
    }
}
