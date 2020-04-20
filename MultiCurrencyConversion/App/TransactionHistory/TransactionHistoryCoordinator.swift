//
//  TransactionHistoryCoordinator.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TransactionHistoryCoordinator: ReactiveCoordinator<TransactionHistoryCoordinator> {
    private let rootViewController: UIViewController
    private let transactionStore: TransactionStore
    
    init(rootViewController: UIViewController, transactionStore: TransactionStore) {
        self.rootViewController = rootViewController
        self.transactionStore = transactionStore
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionHistoryViewController") as! TransactionHistoryViewController
        
        let viewModel = TransactionHistoryViewModel(transactionStore: self.transactionStore)
        viewController.viewModel = viewModel
        
        rootViewController.navigationController?.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
}
