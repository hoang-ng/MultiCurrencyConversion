//
//  TransactionHistoryViewController.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransactionHistoryViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var viewModel: TransactionHistoryViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        self.title = "History"
        
        setupBinding()
        viewModel.getTransaction()
    }
    
    private func setupBinding() {
        viewModel.transactions
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "TransactionCell", cellType: TransactionCell.self)) { (_, txn, cell) in
                cell.transactionIDLabel.text = "TX" + txn.txnID.uuidString.suffix(6)
                cell.transactionDetailLabel?.text = txn.detail()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                cell.dateLabel.text = dateFormatter.string(from: txn.date)
                cell.rateLabel.text = txn.rateString()
        }
        .disposed(by: disposeBag)
    }
}
