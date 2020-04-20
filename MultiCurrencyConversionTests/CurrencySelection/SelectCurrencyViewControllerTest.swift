//
//  SelectCurrencyViewControllerTest.swift
//  MultiCurrencyConversionTests
//
//  Created by Hoang Nguyen on 4/17/20.
//  Copyright © 2020 Hoang Nguyen. All rights reserved.
//

import XCTest
import RxSwift
@testable import MultiCurrencyConversion

class SelectCurrencyViewControllerTest: XCTestCase {

    func test_init() {
        let (sut, viewModel) = makeSUT()
        XCTAssertNotNil(sut)
        XCTAssertNotNil(viewModel)
    }
    
    func test_loadCurrency_rendersUI() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 2)
        
        let cell1 = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let cell2 = sut.tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        
        XCTAssertEqual(cell1?.textLabel?.text, Currency.SGD.rawValue)
        XCTAssertEqual(cell2?.textLabel?.text, Currency.USD.rawValue)
    }
    
    func test_selectCurrency() {
        let disposeBag = DisposeBag()
        let (sut, viewModel) = makeSUT()
        sut.loadViewIfNeeded()
        
        var selectedCurrency: Currency?
        viewModel.selectedCurrency.subscribe(onNext: { currency in
            selectedCurrency = currency
        }).disposed(by: disposeBag)
        sut.tableView.delegate?.tableView?(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0 ))
        XCTAssertNotNil(selectedCurrency)
        XCTAssertEqual(selectedCurrency, Currency.SGD)
    }

    func makeSUT() -> (sut: SelectCurrencyViewController, viewModel: SelectCurrencyViewModel) {
        let sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectCurrencyViewController") as! SelectCurrencyViewController
        let viewModel = SelectCurrencyViewModel(currencies: [.SGD, .USD])
        sut.viewModel = viewModel
        return (sut, viewModel)
    }
}
