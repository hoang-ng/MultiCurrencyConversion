//
//  SelectCurrencyViewController.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SelectCurrencyViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    var viewModel: SelectCurrencyViewModel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        setupUI()
        setupBinding()
    }
    
    func setupUI() {
        self.title = "Select Currency"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: nil)
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func setupBinding() {
        navigationItem.leftBarButtonItem?.rx.tap.bind(to: viewModel.didClose).disposed(by: disposeBag)
        
        viewModel.currencies
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "CurrencyCell", cellType: UITableViewCell.self)) { (_, currency, cell) in
                cell.textLabel?.text = currency.rawValue
        }
        .disposed(by: disposeBag)
        tableView.rx.modelSelected(Currency.self).bind(to: viewModel.selectedCurrency).disposed(by: disposeBag)
    }
}
