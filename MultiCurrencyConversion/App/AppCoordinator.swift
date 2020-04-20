//
//  AppCoordinator.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import RxSwift

class AppCoordinator: ReactiveCoordinator<Void> {
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrencyConversionViewController") as! CurrencyConversionViewController
        let transactionStore = try! CoreDataTransactionStore(storeURL: CoreDataTransactionStore.storeURL)
        let navigationController = UINavigationController(rootViewController: viewController)
        let currencyConversionCoordinator = CurrencyConversionCoordinator(rootViewController: navigationController.viewControllers[0], transactionStore: transactionStore, exchangeRateAPI: ExchangeRateAPI())
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return coordinate(to: currencyConversionCoordinator)
    }
}
