//
//  Atomic.swift
//  TinkoffMockStrapping
//
//  Created by m.monakov on 19.10.2023.
//

import Foundation

final class Atomic<T> {

    private let lock = NSLock()
    private var _value: T

    init(_ value: T) {
        self._value = value
    }

    var value: T {
        lock.lock()
        defer {
            lock.unlock()
        }
        return _value
    }

    func mutate(_ transform: (inout T) -> Void) {
        lock.lock()
        transform(&_value)
        lock.unlock()
    }
}
