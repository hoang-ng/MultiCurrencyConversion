//
//  ExchangeRate.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation

struct ExchangeRate: Equatable {
    var rates: [Currency: Float]
    var baseCurrency: Currency
}
