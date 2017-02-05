//
//  AssociationsTests.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import XCTest
@testable import ReusableView

class AssociationsTests: XCTestCase {
    func testValueType() {
        let instance = TestClass()
        let value = TestStruct(value: 123)
        associate(instance, withValue: value, by: &key)
        
        guard let associated: TestStruct = associated(with: instance, by: &key) else {
            return XCTFail()
        }
        XCTAssertEqual(associated.value, 123)
    }
    
    func testReferenceType() {
        let instance = TestClass()
        let value = TestClass(value: "123")
        associate(instance, withValue: value, by: &key)
        
        guard let associated: TestClass = associated(with: instance, by: &key) else {
            return XCTFail()
        }
        XCTAssertEqual(associated.value, "123")
    }
    
    func testAssociatedPerfomance() {
        let instance = TestClass()
        associate(instance, withValue: "123", by: &key)

        measure {
            (0...1000).forEach({ _ in
                let value: String? = associated(with: instance, by: &key)
                XCTAssertTrue(value == "123")
            })
        }
    }
    
    func testDirectPerfomance() {
        let instance = TestClass()
        instance.value = "321"
        
        measure {
            (0...1000).forEach({ _ in
                let value: String? = instance.value
                XCTAssertTrue(value == "321")
            })
        }
    }
}

private var key = "associated key"

private class TestClass {
    var value: String
    
    init(value: String) {
        self.value = value
    }
    
    init() {
        value = ""
    }
}

private struct TestStruct {
    let value: Int
}
