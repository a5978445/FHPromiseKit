//
//  FHPromise.swift
//  FHPromiseKitDemo
//
//  Created by 李腾芳 on 2019/11/22.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

import UIKit

public class FHPromise<T> {
    
    let value: T
    
    init(value: T) {
        self.value = value
    }
    
    func done(_ process: (T) -> Void)  {
        return process(value)
    }
    
    func map<R>(_ transform: (T) -> R ) -> FHPromise<R> {
        return FHPromise<R>(value: transform(value))
    }
    

}

public func firstly<T>(_ createClosure: () -> FHPromise<T>) -> FHPromise<T> {
    return createClosure()
}
