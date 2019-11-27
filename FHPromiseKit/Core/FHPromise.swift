//
//  FHPromise.swift
//  FHPromiseKitDemo
//
//  Created by 李腾芳 on 2019/11/22.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

/*
 TODO:
 * 严格的单元测试
 * 线程安全
 * 更完整的功能
 * 生命周期管理

 */



public class FHPromise<T>: Catchable {
    
    
    var sink: FHSink<T>
    
    public init(value: T) {
        sink = FHNormalValueSink(value)
    }
    
    public init(_ sinkClosure: @escaping (FHSink<T>) -> Void) {
        sink = FHSink<T>()
        sinkClosure(sink)
    }
    
    public init(_ sink: FHSink<T>) {
        self.sink = sink
    }
    
    @discardableResult
    public func done(_ onfulfill: @escaping (T) -> Void) -> Catchable {
        sink.addfulfillHandle(onfulfill)
        return self
    }
    
    public func `catch`(_ errorHandle: @escaping (Error) -> Void)  {
        sink.addRejectHandle(errorHandle)
        
    }
    
    //
    public func map<R>(_ transform: @escaping (T) -> R) -> FHPromise<R> {
        return FHPromise<R> { sink in
            self.done { result in
                sink.fulfill(transform(result))
            }
        }
    }
    
    /// 构建响应链的关键部分
    public func then<R>(_ transform: @escaping (T) -> FHPromise<R>) -> FHPromise<R> {
        return FHPromise<R>(MergeSink(source: self, transform: transform))
    }
    
    
    
    internal func onEvent(onfulfill: @escaping (T) -> Void, onReject: @escaping (Error) -> Void) {
        sink.addfulfillHandle(onfulfill)
        sink.addRejectHandle(onReject)
    }
}

public func firstly<T>(_ createClosure: () -> FHPromise<T>) -> FHPromise<T> {
    return createClosure()
}


public protocol Catchable {

    func `catch`(_ errorHandle: @escaping (Error) -> Void)
}

