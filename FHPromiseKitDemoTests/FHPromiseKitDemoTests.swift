//
//  FHPromiseKitDemoTests.swift
//  FHPromiseKitDemoTests
//
//  Created by 李腾芳 on 2019/11/22.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

@testable import FHPromiseKitDemo
import XCTest

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

        //   XCTAssert(promise.value == promiseFromFirstlyMethodCreate.value)
    }

    func testDoneOperator_pass() {
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
        .map { "\($0)" }
        .done { result in
            XCTAssert(result == "\(value)")
        }
    }

    func testThenOperator_pass() {
        let value = 3
        firstly {
            return FHPromise(value: value)
        }
        .then { FHPromise<Int>(value: $0 + 1) }
        .done { result in
            XCTAssert(result == value + 1)
        }
    }

    func testContinuesThenOperator_pass() {
        let value = 3
        firstly {
            return FHPromise(value: value)
        }
        .then { FHPromise<Int>(value: $0 + 1) }
        .then { FHPromise<String>(value: "\($0)") }
        .done { result in
            XCTAssert(result == "\(value + 1)")
        }
    }

    func testAsyncPromise() {
        let ex = XCTestExpectation()

        firstly { () -> FHPromise<Int> in
            FHPromise<Int>.init { sink in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    sink.fulfill(3)
                }
            }
        }
        .done { _ in
            ex.fulfill()
        }

        wait(for: [ex], timeout: 0.5)
    }

    func testCatchErrorWithOutDone() {
        let sampleError = NSError(domain: "TestError", code: 999, userInfo: nil)
        var validateError: NSError?
        firstly { () -> FHPromise<Int> in
            FHPromise<Int>.init { sink in
                sink.reject(sampleError)
            }
        }
        .catch { error in
            validateError = error as NSError
        }

        XCTAssert(validateError == sampleError)
    }
    
    func testCatchErrorWithDone() {
        let sampleError = NSError(domain: "TestError", code: 999, userInfo: nil)
               var validateError: NSError?
               firstly { () -> FHPromise<Int> in
                   FHPromise<Int>.init { sink in
                       sink.reject(sampleError)
                   }
               }
               .done { _ in }
               .catch { error in
                   validateError = error as NSError
               }

               XCTAssert(validateError == sampleError)
    }
    

    // 测试第二个promise错误
    func testSecondError() {
        let sampleError = NSError(domain: "TestError", code: 999, userInfo: nil)
        var validateError: NSError?

        let ex = XCTestExpectation()

        firstly { () -> FHPromise<Int> in
            FHPromise<Int>.init { sink in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    sink.fulfill(3)
                }
            }
        }
        .then { _ in
            FHPromise<Int> { sink in
                sink.reject(sampleError)
            }
        }
        .catch { error in
            validateError = error as NSError
            ex.fulfill()
        }

        wait(for: [ex], timeout: 0.5)
        XCTAssert(validateError == sampleError)
    }
    
    func testMutipleSubscirbe() {
        let ex = XCTestExpectation()
        var subscribe1Excute =  false
        var subscribe2Excute = false
        var subscribe3Excute = false

       let promise = firstly { () -> FHPromise<Int> in
            FHPromise<Int>.init { sink in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    sink.fulfill(3)
                }
            }
        }
        promise.done { _ in
            subscribe1Excute = true
            
        }
        
        promise.done { _ in
            subscribe2Excute = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            promise.done { _ in
                subscribe3Excute = true
                ex.fulfill()
            }
        }

        wait(for: [ex], timeout: 3)
        XCTAssertTrue(subscribe1Excute)
        XCTAssertTrue(subscribe2Excute)
        XCTAssertTrue(subscribe3Excute)
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
