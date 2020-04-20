//
//  ExchangeRateAPI.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import Alamofire

class ExchangeRateAPI: ExchangeRateAPIProtocol {
    func getExchangeRate(baseCurrency: Currency, completion: @escaping (Result<ExchangeRate, Error>) -> ()) {
        var url = "https://api.exchangeratesapi.io/latest?symbols=SGD,MYR,USD,EUR&base=" + baseCurrency.rawValue
        if baseCurrency == .EUR {
            url = "https://api.exchangeratesapi.io/latest?symbols=SGD,MYR,USD"
        }
        
        AF.request(url, parameters: nil).responseJSON { response in
            switch response.result {
            case let .success(rate):
                var exchangeRateModel = ExchangeRate(rates: [Currency : Float](), baseCurrency: .SGD)
                if let json = rate as? [String: Any] {
                    if let rates = json["rates"] as? [String: NSNumber] {
                        for (key, value) in rates {
                            if let currency = Currency(rawValue: key) {
                                exchangeRateModel.rates[currency] = value.floatValue
                            }
                        }
                        if baseCurrency == .EUR {
                            exchangeRateModel.rates[.EUR] = 1
                        }
                    }
                    if let base = json["base"] as? String, let currency = Currency(rawValue: base) {
                        exchangeRateModel.baseCurrency = currency
                    }
                    completion(.success(exchangeRateModel))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
