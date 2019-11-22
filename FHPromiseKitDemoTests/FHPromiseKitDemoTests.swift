//
//  FHPromiseKitDemoTests.swift
//  FHPromiseKitDemoTests
//
//  Created by 李腾芳 on 2019/11/22.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

import XCTest
@testable import FHPromiseKitDemo

class FHPromiseKitDemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFirstlyInit_pass() {
        let promise = FHPromise(value: 3)
        let promiseFromFirstlyMethodCreate = firstly {
            return FHPromise(value: 3)
        }
        
        XCTAssert(promise.value == promiseFromFirstlyMethodCreate.value)
    }
    
    func testThenOperator_pass() {
        let value = 3
        firstly {
            return FHPromise(value: value)
        }
        .done { result in
            XCTAssert(value == result)
        }
        
    }
    
    func testMapOperator_pass() {
        let value = 3
        firstly {
            return FHPromise(value: value)
        }
        .map {  "\($0)" }
        .done { result in
            XCTAssert(result == "\(value)")
        }
        
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
