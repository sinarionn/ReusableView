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

class NonReusableViewTests: XCTestCase {
    
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
    
    func testFlow() {
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
    
}

class TestNonReusable: NonReusableViewProtocol {
    var receivedViewModel: String?
    var prepareForUsageCalled: Int = 0
    var errorReceivedViewModel: String?
    
    func onUpdate(with viewModel: String, disposeBag: DisposeBag) {
        receivedViewModel = viewModel
    }
    
    func prepareForUsage() {
        prepareForUsageCalled += 1
    }
    
    func onAttemptToReuse(with viewModel: String?) {
        errorReceivedViewModel = viewModel
    }
}
