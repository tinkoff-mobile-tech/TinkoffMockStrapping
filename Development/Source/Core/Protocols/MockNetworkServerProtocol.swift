//
//  MockNetworkServerProtocol.swift
//  TinkoffMockStrapping
//
//  Created by v.rudnevskiy on 19.02.2021.
//

import Foundation

/// Представляет свойство и набор методов для взаимодействия с сервером.
/// Network server protocol
public protocol MockNetworkServerProtocol {

    /// Представляет псевдоним для типа сервера.
    /// Server associated type
    associatedtype NetworkServer

    /// Сервер для подмены сетевых запросов.
    /// Mock server
    var server: NetworkServer { get }

    /// Хранилище используемых стабов.
    /// Stubs storage
    var stubs: [NetworkStubProtocol] { get }

    /// Метод для запуска сервера.
    /// - Returns: Порт, на котором запущен сервер.
    /// Starts the server
    /// - Returns: port number
    func start() -> UInt16?

    /// Метод для остановки сервера.
    /// Stops the server
    func stop()

    /// Метод для добавления нового стаба.
    /// Adds new stub
    func setStub(_: NetworkStubProtocol)

    /// Метод для удаления существующего стаба.
    /// Removes stub
    func removeStub(_: NetworkStubProtocol)

    /// Метод для удаления всех существующих стабов.
    /// Removes all stubs
    func removeAllStubs()
}
