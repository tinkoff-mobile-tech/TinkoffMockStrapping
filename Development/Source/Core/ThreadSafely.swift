//
//  ThreadSafely.swift
//  TinkoffMockStrapping
//
//  Created by v.rudnevskiy on 19.10.2021.
//

import Foundation

@propertyWrapper
struct ThreadSafely<Value> {

    private var value: Value
    private let queue = DispatchQueue(label: "ru.tcsenterprise.core.ios.tinkoffmockstrapping.threadSafely")

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }
}
