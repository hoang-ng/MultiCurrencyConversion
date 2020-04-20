//
//  SelectCurrencyCoordinator.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum SelectCurrencyCoordinationResult {
    case currency(Currency)
    case cancel
}

class SelectCurrencyCoordinator: ReactiveCoordinator<SelectCurrencyCoordinationResult> {
    private let rootViewController: UIViewController
    private let currencies: [Currency]!
    
    init(rootViewController: UIViewController, currencies: [Currency]) {
        self.rootViewController = rootViewController
        self.currencies = currencies
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectCurrencyViewController") as! SelectCurrencyViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let viewModel = SelectCurrencyViewModel(currencies: self.currencies)
        viewController.viewModel = viewModel
        
        let currency = viewModel.selectedCurrency.map { CoordinationResult.currency($0) }
        
        let cancel = viewModel.didClose.map { _ in
            CoordinationResult.cancel
        }
        
        rootViewController.present(navigationController, animated: true, completion: nil)
        
        return Observable.merge(currency, cancel)
            .take(1)
            .do(onNext: { _ in
                viewController.dismiss(animated: true, completion: nil)
            })
    }
}
