//
//  FHSink.swift
//  FHPromiseKitDemo
//
//  Created by 李腾芳 on 2019/11/27.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//




public class FHSink<T> {
    enum Event {
        case fulfill(T)
        case reject(Error)
    }

    var event: Event? {
        didSet {
            guard let event = event else {
                return
            }
            
            switch event {
            case let .fulfill(value):
                onfulfills.forEach { $0(value) }
            case let .reject(error):
                onRejects.forEach { $0(error) }
            }
        }
    }
    var onfulfills = [(T) -> Void]()

    var onRejects = [(Error) -> Void]()

    public func fulfill(_ value: T) {
        guard event == nil else {
            return
        }
        event = .fulfill(value)
     
    }

    public func reject(_ error: Error) {
        guard event == nil else {
            return
        }
        event = .reject(error)
    }
    
    func addfulfillHandle(_ handle: @escaping (T) -> Void) {
        onfulfills.append(handle)
        if case let .fulfill(value) = event {
            handle(value)
        }
    }
    
    func addRejectHandle(_ handle: @escaping (Error) -> Void) {
        onRejects.append(handle)
        if case let .reject(error) = event {
            handle(error)
        }
    }
    
}

public class FHNormalValueSink<T>: FHSink<T> {
    init(_ value: T) {
        super.init()
        event = .fulfill(value)
    }
}

// 这个类是构建响应链的关键
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
