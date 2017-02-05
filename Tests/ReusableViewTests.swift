//
//  NonReusableViewTests.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import ReusableView

class ReusableViewTests: XCTestCase {
    
    func testReuseBagOnEquatableVM() {
        let object = TestReusable<String>()
        var value: Int = 0
        object.rx.reuseBag.insert(Disposables.create {
            value = 1
        })
        object.viewModel = "1"
        XCTAssertTrue(value == 1)
        object.rx.reuseBag.insert(Disposables.create {
            value = 2
        })
        object.viewModel = "2"
        XCTAssertTrue(value == 2)
        object.rx.reuseBag.insert(Disposables.create {
            value = 3
        })
        object.viewModel = "3"
        XCTAssertTrue(value == 3)
    }
    
    func testReuseBagOnNonEquatableVM() {
        let object = TestReusable<TestableNonEquatable>()
        var value: Int = 0
        object.rx.reuseBag.insert(Disposables.create {
            value = 1
        })
        object.viewModel = TestableNonEquatable()
        XCTAssertTrue(value == 1)
        object.rx.reuseBag.insert(Disposables.create {
            value = 2
        })
        object.viewModel = TestableNonEquatable()
        XCTAssertTrue(value == 2)
        object.rx.reuseBag.insert(Disposables.create {
            value = 3
        })
        object.viewModel = TestableNonEquatable()
        XCTAssertTrue(value == 3)        
    }
    
    func testDisposeBag() {
        var object : TestReusable<String>? = TestReusable()
        var disposeCalled = false
        object?.rx.disposeBag.insert(Disposables.create{
            disposeCalled = true
        })
        XCTAssertTrue(disposeCalled == false)
        object = nil
        XCTAssertTrue(disposeCalled == true)
    }
    
    func testFlow() {
        let object = TestReusable<TestableNonEquatable>()
        
        XCTAssertNil(object.viewModel)
        XCTAssertTrue(object.prepareForUsageCalled == 0)
        XCTAssertTrue(object.prepareForReuseCalled == 0)
        
        
        let instance0 = TestableNonEquatable()
        object.viewModel = instance0
        XCTAssertTrue(object.viewModel === instance0)
        XCTAssertTrue(object.receivedViewModel === instance0)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 1)
        object.receivedViewModel = nil
        
        let instance1 = TestableNonEquatable()
        object.viewModel = instance1
        XCTAssertTrue(object.viewModel === instance1)
        XCTAssertTrue(object.receivedViewModel === instance1)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 2)
        object.receivedViewModel = nil
        
        let instance2 = TestableNonEquatable()
        object.viewModel = instance2
        XCTAssertTrue(object.viewModel === instance2)
        XCTAssertTrue(object.receivedViewModel === instance2)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 3)
        object.receivedViewModel = nil
        
        object.viewModel = nil
        XCTAssertTrue(object.viewModel == nil)
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 4)
    }
    
    func testDistinctiveFlow() {
        let object : TestReusable = TestDistinctiveReusable()
        
        XCTAssertNil(object.viewModel)
        XCTAssertTrue(object.prepareForUsageCalled == 0)
        XCTAssertTrue(object.prepareForReuseCalled == 0)
        
        object.viewModel = "123"
        XCTAssertTrue(object.viewModel == "123")
        XCTAssertTrue(object.receivedViewModel == "123")
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 1)
        object.receivedViewModel = nil
        
        object.viewModel = "123"
        XCTAssertTrue(object.viewModel == "123")
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 1)
        object.receivedViewModel = nil
        
        object.viewModel = "321"
        XCTAssertTrue(object.viewModel == "321")
        XCTAssertTrue(object.receivedViewModel == "321")
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 2)
        object.receivedViewModel = nil
        
        object.viewModel = nil
        XCTAssertTrue(object.viewModel == nil)
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.prepareForReuseCalled == 3)
    }
    
}

protocol ViewModelProtocol {
    var observable: Observable<String> { get }
}

class ReusableView: UIView, ReusableViewProtocol {
    @IBOutlet weak var label: UILabel!
    
    func onUpdate(with viewModel: ViewModelProtocol, disposeBag: DisposeBag) {
        viewModel.observable.bindTo(label.rx.text).addDisposableTo(disposeBag)
    }
}


fileprivate class TestableNonEquatable {
}

fileprivate class TestReusable<T>: ReusableViewProtocol {
    var receivedViewModel: T?
    var prepareForUsageCalled: Int = 0
    var prepareForReuseCalled: Int = 0
    
    fileprivate func onUpdate(with viewModel: T, disposeBag: DisposeBag) {
        receivedViewModel = viewModel
    }

    func prepareForUsage() {
        prepareForUsageCalled += 1
    }
    
    func prepareForReuse() {
        prepareForReuseCalled += 1
    }
}

fileprivate class TestDistinctiveReusable: TestReusable<String>, DistinctiveReuse { }
