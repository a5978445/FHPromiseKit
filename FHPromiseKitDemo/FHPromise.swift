//
//  FHPromise.swift
//  FHPromiseKitDemo
//
//  Created by 李腾芳 on 2019/11/22.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

import UIKit

/*
 TODO:
 * 严格的单元测试
 * 线程安全
 * 更完整的功能

 */

public class FHSink<T> {
    enum Event {
        case fulfill(T)
        case reject(Error)
    }

    var event: Event?
    var onfulfill: ((T) -> Void)? {
        didSet {
            if let onfulfill = onfulfill, case let .fulfill(value) = event {
                onfulfill(value)
            }
        }
    }

    var onReject: ((Error) -> Void)? {
        didSet {
            if let onReject = onReject, case let .reject(error) = event {
                onReject(error)
            }
        }
    }

    func fulfill(_ value: T) {
        event = .fulfill(value)
        onfulfill?(value)
    }

    func reject(_ error: Error) {
        event = .reject(error)
        onReject?(error)
    }

//    func subscribe(onfulfill: (T) -> (), onError: Error) {
//
//    }
}

public class FHNormalValueSink<T>: FHSink<T> {
    init(_ value: T) {
        super.init()
        event = .fulfill(value)
    }
}

// 这个类是构建相应链的关键
// 如果不能减少范型的数量，随着相应链长度增加，范型数量必然增加
// 这里通过继承的方式，成功减少最终的范型数量
public class MergeSink<V, T>: FHSink<T> {
    let source: FHPromise<V>
    let transform: (V) -> FHPromise<T>

    init(source: FHPromise<V>, transform: @escaping (V) -> FHPromise<T>) {
        self.source = source
        self.transform = transform

        super.init()
        connect()
    }

//    最终还是需要嵌套，逻辑越复杂代码越脏，但关键是你决定让代码脏在哪个部分
    func connect() {
        source.done { result in
            self.transform(result)
                .onEvent(onfulfill: { finalResult in
                    self.fulfill(finalResult)
                }, onReject: { error in
                    self.reject(error)
                })
        }
    }
}

public class FHPromise<T> {
    var sink: FHSink<T>

    init(value: T) {
        sink = FHNormalValueSink(value)
    }

    init(_ sinkClosure: @escaping (FHSink<T>) -> Void) {
        sink = FHSink<T>()
        sinkClosure(sink)
    }

    init(_ sink: FHSink<T>) {
        self.sink = sink
    }

    func done(_ onfulfill: @escaping (T) -> Void) {
        sink.onfulfill = onfulfill
    }

    //
    func map<R>(_ transform: @escaping (T) -> R) -> FHPromise<R> {
        return FHPromise<R> { sink in
            self.done { result in
                sink.fulfill(transform(result))
            }
        }
    }

    /// 构建响应链的关键部分
    func then<R>(_ transform: @escaping (T) -> FHPromise<R>) -> FHPromise<R> {
        return FHPromise<R>(MergeSink(source: self, transform: transform))
    }

    func `catch`(_ errorHandle: @escaping (Error) -> Void) {
        sink.onReject = errorHandle
    }

    internal func onEvent(onfulfill: @escaping (T) -> Void, onReject: @escaping (Error) -> Void) {
        sink.onfulfill = onfulfill
        sink.onReject = onReject
    }
}

public func firstly<T>(_ createClosure: () -> FHPromise<T>) -> FHPromise<T> {
    return createClosure()
}
