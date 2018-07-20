//
//  NonReusableViewTests.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import XCTest
import RxSwift

@testable import ReusableView

class ReusableViewTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
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
        XCTAssertTrue(object.viewModelWillUpdateCalled == 0)
        
        
        let instance0 = TestableNonEquatable()
        object.viewModel = instance0
        XCTAssertTrue(object.viewModel === instance0)
        XCTAssertTrue(object.receivedViewModel === instance0)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 1)
        object.receivedViewModel = nil
        
        let instance1 = TestableNonEquatable()
        object.viewModel = instance1
        XCTAssertTrue(object.viewModel === instance1)
        XCTAssertTrue(object.receivedViewModel === instance1)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 2)
        object.receivedViewModel = nil
        
        let instance2 = TestableNonEquatable()
        object.viewModel = instance2
        XCTAssertTrue(object.viewModel === instance2)
        XCTAssertTrue(object.receivedViewModel === instance2)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 3)
        object.receivedViewModel = nil
        
        object.viewModel = nil
        XCTAssertTrue(object.viewModel == nil)
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 4)
    }
    
    func testDistinctiveFlow() {
        let object : TestReusable = TestDistinctiveReusable()
        
        XCTAssertNil(object.viewModel)
        XCTAssertTrue(object.prepareForUsageCalled == 0)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 0)
        
        object.viewModel = "123"
        XCTAssertTrue(object.viewModel == "123")
        XCTAssertTrue(object.receivedViewModel == "123")
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 1)
        object.receivedViewModel = nil
        
        object.viewModel = "123"
        XCTAssertTrue(object.viewModel == "123")
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 1)
        object.receivedViewModel = nil
        
        object.viewModel = "321"
        XCTAssertTrue(object.viewModel == "321")
        XCTAssertTrue(object.receivedViewModel == "321")
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 2)
        object.receivedViewModel = nil
        
        object.viewModel = nil
        XCTAssertTrue(object.viewModel == nil)
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.viewModelWillUpdateCalled == 3)
    }
    
    func testViewModelObserver() {
        let object : TestReusable = TestDistinctiveReusable()
        let expect = expectation(description: "")
        _ = object.rx.viewModelDidUpdate.take(1).subscribe(onNext: {
            XCTAssert($0.0 == object.receivedViewModel)
            XCTAssert($0.0 == "a")
            _ = object.rx.viewModelDidUpdate.take(1).subscribe(onNext: {
                XCTAssert($0.0 == object.receivedViewModel)
                XCTAssert($0.0 == "b")
                expect.fulfill()
            })
            object.viewModel = "b"
        })
        object.viewModel = "a"
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testViewModelStruct() {
        let reusable = TestReusable<TestStruct>()
        reusable.viewModel = TestStruct(value: "1")
        XCTAssertTrue(reusable.viewModel?.value == "1")
    }
    
    func testViewModelStructErased() {
        let reusable = TestReusable<TestStructType>()
        reusable.viewModel = TestStruct(value: "1") as TestStructType
        XCTAssertTrue(reusable.viewModel?.value == "1")
    }
    
    func testBinder() {
        let reusable = TestReusable<String>()
        let relay = BehaviorSubject<String>(value: "123")
        relay.bind(to: reusable.rx.viewModel).disposed(by: disposeBag)
        XCTAssertEqual(reusable.viewModel, "123")
        relay.onNext("321")
        XCTAssertEqual(reusable.viewModel, "321")
    }
    
    func testOptionalBinder() {
        let reusable = TestReusable<String>()
        let relay = BehaviorSubject<String?>(value: "123")
        relay.bind(to: reusable.rx.viewModel).disposed(by: disposeBag)
        XCTAssertEqual(reusable.viewModel, "123")
        relay.onNext(nil)
        XCTAssertEqual(reusable.viewModel, nil)
        relay.onNext("321")
        XCTAssertEqual(reusable.viewModel, "321")
    }
}

fileprivate struct TestStruct: TestStructType {
    let value: String
}

protocol TestStructType {
    var value: String { get }
}

fileprivate class TestableNonEquatable {
}

fileprivate class TestReusable<T>: ReusableType {
    var receivedViewModel: T?
    var prepareForUsageCalled: Int = 0
    var viewModelWillUpdateCalled: Int = 0
    
    fileprivate func onUpdate(with viewModel: T, reuseBag: DisposeBag) {
        receivedViewModel = viewModel
    }

    func prepareForUsage() {
        prepareForUsageCalled += 1
    }
    
    func viewModelWillUpdate() {
        viewModelWillUpdateCalled += 1
    }
}

fileprivate class TestDistinctiveReusable: TestReusable<String>, DistinctiveReuse { }
