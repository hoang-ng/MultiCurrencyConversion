//
//  SelectCurrencyViewModel.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SelectCurrencyViewModel {
    private let dispoaseBag = DisposeBag()
    
    let currencies = BehaviorRelay<[Currency]>(value: [])
    
    // MARK: - Actions
    let didClose = PublishSubject<Void>()
    let selectedCurrency = PublishSubject<Currency>()
    
    init(currencies: [Currency]) {
        self.currencies.accept(currencies)
    }
}
