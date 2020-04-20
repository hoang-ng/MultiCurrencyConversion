//
//  ExchangeRateAPI.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation

protocol ExchangeRateAPIProtocol {
    func getExchangeRate(baseCurrency: Currency, completion: @escaping (Result<ExchangeRate, Error>) -> ())
}
