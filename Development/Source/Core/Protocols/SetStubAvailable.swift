//
//  SetStubAvailable.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 03.09.2020.
//

import Foundation
import SwiftyJSON

/// Протокол для доступа к средствам мокирования.
/// Mocker protocol
public protocol SetStubAvailable {

    /// Представляет псевдоним для типа сервера.
    /// Associated type for the servers type
    associatedtype NetworkServer

    /// Сервер для подмены сетевых запросов.
    /// Mock server
    var network: NetworkServer { get }
}

// MARK: - Extensions

public extension SetStubAvailable where NetworkServer: MockNetworkServerProtocol {

    /// Устанавливает стаб для подмены сетевого запроса.
    /// - Parameters:
    ///   - stub: Стаб для установки.
    ///   - jsonModifier: Функция, изменяющая JSON перед передачей сетевому клиенту.
    /// Sets the stub
    /// - Parameters:
    ///   - stub: stub.
    ///   - jsonModifier: function for changing json
    @discardableResult
    func setStub<Stub: NetworkStubProtocol>(_ stub: Stub, jsonModifier: ((Stub) -> Void)? = nil) -> Self {
        jsonModifier?(stub)
        network.setStub(stub)
        return self
    }

    /// Установливает сразу несколько стабов.
    /// - Parameter stubs: Коллекция стабов.
    /// Sets stubs
    /// - Parameter stubs: Stubs collection
    @discardableResult
    func setStubs<Stub: NetworkStubProtocol>(_ stubs: Stub...) -> Self {
        stubs.forEach { self.setStub($0) }
        return self
    }

    /// Удаляет указанный стаб.
    /// - Parameter stub: Стаб для удаления.
    /// Removes the stub
    /// - Parameter stub: stub for removing
    @discardableResult
    func removeStub<Stub: NetworkStubProtocol>(_ stub: Stub) -> Self {
        network.removeStub(stub)
        return self
    }

    /// Удаляет сразу несколько стабов.
    /// - Parameter stubs: Коллекция стабов.
    /// Removes stubs
    /// - Parameter stubs: stubs collection
    @discardableResult
    func removeStubs<Stub: NetworkStubProtocol>(_ stubs: Stub...) -> Self {
        stubs.forEach { self.removeStub($0) }
        return self
    }

    /// Удаляет все записанные стабы.
    /// Removes all stubs
    @discardableResult
    func removeAllStubs() -> Self {
        network.removeAllStubs()
        return self
    }
}
