//
//  ViewController.swift
//  MultiCurrencyConversion
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class CurrencyConversionViewController: UIViewController {
    
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var fromCurrencyButton: UIButton!
    @IBOutlet var toCurrencyButton: UIButton!
    @IBOutlet var convertButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var fromAmountTextField: UITextField!
    @IBOutlet var toAmountTextField: UITextField!
    
    var viewModel: CurrencyConversionViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        viewModel.getWalletBalance()
    }
    
    func setupBinding() {
        setupBindingLoading()
        setupBindingSelectCurrencyButtons()
        setupBindingCurrentBalance()
        setupBindingCurrentExchangeRate()
        setupBindingBottomButtons()
        setupBindingShowAlert()
    }
    
    func setupBindingLoading() {
        viewModel.isLoading.subscribe(onNext: { isLoading in
            if isLoading {
                SVProgressHUD.show()
            } else {
                SVProgressHUD.dismiss()
            }
        })
        .disposed(by: disposeBag)
    }
    
    func setupBindingCurrentBalance() {
        viewModel.currentBalance.map { balance in
            if let balance = balance {
                return String(format: "%.2f", balance.amount)
            }
            return ""
        }
        .bind(to: balanceLabel.rx.text).disposed(by: disposeBag)
    }
    
    func setupBindingCurrentExchangeRate() {
        viewModel.currentExchangeRate
            .map { [weak self] exchangeRate -> String in
                guard let `self` = self, let exchangeRate = exchangeRate else { return "" }
                return self.viewModel.getExchangeRate(exchangeRate: exchangeRate)
        }
        .bind(to: rateLabel.rx.text).disposed(by: disposeBag)
    }
    
    func setupBindingSelectCurrencyButtons() {
        fromCurrencyButton.rx.tap.do(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).bind(to: viewModel.selectFromCurrency).disposed(by: disposeBag)
        toCurrencyButton.rx.tap.do(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).bind(to: viewModel.selectToCurrency).disposed(by: disposeBag)
        
        viewModel.selectedFromCurrency
            .map { $0.rawValue }
            .bind(to: fromCurrencyButton.rx.title()).disposed(by: disposeBag)
        viewModel.selectedToCurrency
            .map { $0.rawValue }
            .bind(to: toCurrencyButton.rx.title()).disposed(by: disposeBag)
        viewModel.convertedFromAmount.bind(to: fromAmountTextField.rx.text).disposed(by: disposeBag)
        viewModel.convertedToAmount.bind(to: toAmountTextField.rx.text).disposed(by: disposeBag)
        
        fromAmountTextField.rx.text.bind(to: viewModel.fromAmount).disposed(by: disposeBag)
        toAmountTextField.rx.text.bind(to: viewModel.toAmount).disposed(by: disposeBag)
    }
    
    func setupBindingBottomButtons() {
        convertButton.rx.tap.map({ [weak self] _ -> String in
            guard let `self` = self else { return "" }
            return self.fromAmountTextField.text ?? ""
        })
        .bind(to: viewModel.convertCurrency).disposed(by: disposeBag)
        historyButton.rx.tap.bind(to: viewModel.viewHistory).disposed(by: disposeBag)
    }
    
    func setupBindingShowAlert() {
        viewModel.showConvertConfirmationAlert
            .subscribe(onNext: { [weak self] message in
                guard let `self` = self else { return }
                let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
                    self.viewModel.addTransaction.onNext(self.fromAmountTextField.text ?? "")
                }
                let action2 = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(action1)
                alertController.addAction(action2)
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        viewModel.showConvertFailAlert
            .subscribe(onNext: { [weak self] message in
                guard let `self` = self else { return }
                let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                    self.viewModel.addTransaction.onNext(self.fromAmountTextField.text ?? "")
                }
                alertController.addAction(action1)
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension CurrencyConversionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         let s = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
         guard !s.isEmpty else { return true }
         let numberFormatter = NumberFormatter()
         numberFormatter.numberStyle = .none
         return numberFormatter.number(from: s)?.intValue != nil
    }
}
