//
//  Transaction.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation

struct Transaction: Equatable {
    var txnID: UUID
    var date: Date
    var fromCurrency: String
    var toCurrency: String
    var fromAmount: Double
    var rate: Float
    var toAmount: Double {
        return fromAmount * Double(rate)
    }
}

extension Transaction {
    func detail() -> String {
        return fromCurrency + String(format: "%.2f", fromAmount) + " -> " + toCurrency + String(format: "%.2f", toAmount)
    }
    
    func rateString() -> String {
        return fromCurrency + "1 to " + toCurrency + String(format: "%.2f", rate)
    }
}
