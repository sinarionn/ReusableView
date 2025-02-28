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

class NonReusableViewTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    func testDisposeBag() {
        var object : TestNonReusable? = TestNonReusable()
        var disposeCalled = false
        object?.rx.disposeBag.insert(Disposables.create{
            disposeCalled = true
        })
        XCTAssertTrue(disposeCalled == false)
        object = nil
        XCTAssertTrue(disposeCalled == true)
    }
    
    @MainActor func testFlow() {
        let object = TestNonReusable()
        
        XCTAssertNil(object.viewModel)
        XCTAssertTrue(object.receivedViewModel == nil)
        XCTAssertTrue(object.prepareForUsageCalled == 0)
        XCTAssertNil(object.errorReceivedViewModel)
        
        object.viewModel = "123"
        XCTAssertTrue(object.viewModel == "123")
        XCTAssertTrue(object.receivedViewModel == "123")
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertNil(object.errorReceivedViewModel)
        
        object.viewModel = "321"
        XCTAssertTrue(object.viewModel == "123")
        XCTAssertTrue(object.receivedViewModel == "123")
        XCTAssertTrue(object.prepareForUsageCalled == 1)
        XCTAssertTrue(object.errorReceivedViewModel == "321")
    }
    
    @MainActor func testViewModelObserver() {
        let object = TestNonReusable()
        let expect = expectation(description: "")
        _ = object.rx.viewModelDidUpdate.take(1).subscribe(onNext: {
            XCTAssert($0.0 == object.receivedViewModel)
            XCTAssert($0.0 == "a")
            expect.fulfill()
        })
        object.viewModel = "a"
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @MainActor func testBinder() {
        let container = TestNonReusable()
        let relay = BehaviorSubject<String>(value: "123")
        relay.bind(to: container.rx.viewModel).disposed(by: disposeBag)
        XCTAssertEqual(container.viewModel, "123")
    }
    
    @MainActor func testOptionalBinder() {
        let container = TestNonReusable()
        let relay = BehaviorSubject<String?>(value: "123")
        relay.bind(to: container.rx.viewModel).disposed(by: disposeBag)
        XCTAssertEqual(container.viewModel, "123")
        relay.onNext("321")
        XCTAssertEqual(container.errorReceivedViewModel, "321")
    }
}

class TestNonReusable: NonReusableType {
    var receivedViewModel: String?
    var prepareForUsageCalled: Int = 0
    var errorReceivedViewModel: String?
    
    func onUpdate(with viewModel: String, reuseBag: DisposeBag) {
        receivedViewModel = viewModel
    }
    
    func prepareForUsage() {
        prepareForUsageCalled += 1
    }
    
    func onAttemptToReuse(with viewModel: String?) {
        errorReceivedViewModel = viewModel
    }
}
