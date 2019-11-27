//
//  ViewController.swift
//  FHPromiseKitDemo
//
//  Created by 李腾芳 on 2019/11/22.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//


import UIKit
import FHPromiseKit

enum NetworkingResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

class ViewController: UIViewController {
    
    var promise: FHPromise<HTTPURLResponse>!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // send request

        // then print result

        // 正常的使用
        mockRequestSuccess(URLRequest(url: URL(string: "http://www.jianshu.com")!)) { result in
            switch result {
            case let .success(httpResponse):
                print("success")
            case let .failure(error):
                print("failure")
            }
        }

        let promise = firstly { () -> FHPromise<HTTPURLResponse> in
            return createPromise()
        }

        promise.done { _ in
            print("work is done")
        }
//        .catch { _ in
//        }
//        .finally {
//            print("finally excute")
//        }
//
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
//            promise.done { response in
//                       print("work is done")
//                   }
//        }
        
        self.promise = createPromise()
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }

    func createPromise() -> FHPromise<HTTPURLResponse> {
        return FHPromise { resolver in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 20) {
                print("async excute")
                resolver.fulfill(HTTPURLResponse())
            }
        }
    }

    func mockRequestSuccess(_: URLRequest, completion: @escaping (NetworkingResult) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            completion(.success(HTTPURLResponse()))
        }
    }
}
