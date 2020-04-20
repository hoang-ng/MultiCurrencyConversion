//
//  MockTransactionHistoryViewModel.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
@testable import MultiCurrencyConversion

class MockTransactionHistoryViewModel: TransactionHistoryViewModel {
    
    var isGetTransaction = false
    override func getTransaction() {
        self.isGetTransaction = true
        super.getTransaction()
    }
}
