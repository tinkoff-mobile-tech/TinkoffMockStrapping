//
//  BaseNetworkMocker.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 14.10.2021.
//

import Foundation
import SwiftyJSON

/// Представляет основу сетевого сервера или клиента для подмены сетевых запросов.
/// Base class for network mock server or client
open class BaseNetworkMocker {

    @ThreadSafely
    private var historyStorage: [(request: HttpRequestProtocol, response: NetworkStubResponse)] = []

    /// Логирует сетевые запросы.
    /// Loggs requests
    public let logger: NetworkStubLoggerProtocol?

    /// Хранилище стабов.
    /// Stubs storage
    public private(set) var stubs: [NetworkStubProtocol] = []

    /// Инициализирует класс сервера.
    /// Initializer
    public init(logger: NetworkStubLoggerProtocol?) {
        self.logger = logger
    }

    // MARK: Stub Management API

    /// Применяет указанный стаб ко всем будущим запросам.
    /// - Parameter stub: Стаб для подмены ответа.
    /// Stub setter
    /// - Parameter stub: stub
    open func setStub(_ stub: NetworkStubProtocol) {
        removeStub(stub)
        stubs.append(stub)
    }

    /// Удаляет указанный стаб из коллекции установленных стабов.
    /// - Parameter stub: Стаб для удаления.
    /// Removes stub
    /// - Parameter stub: stub for removing
    open func removeStub(_ stub: NetworkStubProtocol) {
        stubs.removeAll { $0.request == stub.request }
    }

    /// Удаляет все стабы из коллекции установленных стабов.
    /// Removes all stubs
    open func removeAllStubs() {
        stubs.removeAll()
    }
}

// MARK: - History Management API

extension BaseNetworkMocker: MockNetworkHistoryProtocol {

    /// Хранилище запросов с ответами на них.
    /// Requests and response storage
    public var history: [(request: HttpRequestProtocol, response: NetworkStubResponse)] { historyStorage }

    /// Очищает историю запросов.
    /// Clear requests history
    public func clearHistory() {
        historyStorage.removeAll()
    }

    /// Проверяет, был ли выполнен запрос по указанному URL с указанными параметрами.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    /// Returns `true` if the request with `url` was invoked
    /// - Parameters:
    ///   - url: url
    ///   - query: request query params
    public func wasInvoked(url: String, query parameters: [String: String] = [:]) -> Bool {
        return invokedTimes(NetworkStubRequest(url: url, query: parameters, bodyJson: nil)) > 0
    }

    /// Проверяет, сколько раз был выполнен запрос по указанному URL с указанными параметрами.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    /// Returns the number of times request with `url` was invoked
    /// - Parameters:
    ///   - url: url
    ///   - query: request query params
    public func invokedTimes(url: String, query parameters: [String: String] = [:]) -> Int {
        return invokedTimes(NetworkStubRequest(url: url, query: parameters, bodyJson: nil))
    }

    // MARK: Private

    private func invokedTimes(_ historyEntry: HttpRequestProtocol) -> Int {
        return historyStorage.filter { entry, _ in
            entry.url == historyEntry.url && historyEntry.query.allSatisfy { entry.query[$0.key] == $0.value }
        }.count
    }
}

// MARK: - Public API

public extension BaseNetworkMocker {

    /// Возвращает наиболее подходящий стаб для указанного сетевого запроса и записывает запрос в историю.
    /// - Parameter request: Сетевой запрос.
    /// - Returns: Подходящий стаб или `nil`.
    /// Returns http-response for the request
    /// - Parameters:
    ///   - request: http-request
    /// - Returns: http-response based on found stub or nil
    func getResponseStub(for request: HttpRequestProtocol) -> NetworkStubProtocol? {

        // Выбираем все подходящие стабы, затем сортируем их по количеству параметров запроса и
        // берем тот стаб, у которого больше всего параметров запроса. Он должен лучше всего подходить.
        let matchedStub = stubs
            .filter { $0.request.matches(to: request) }
            .sorted { $0.request.query.count > $1.request.query.count }
            .sorted { $0.request.headersDictionary.count > $1.request.headersDictionary.count }
            .first

        let historyRequest = HistoryHttpRequest(url: request.url,
                                                query: request.query,
                                                bodyJson: request.bodyJson,
                                                httpMethod: request.httpMethod,
                                                headersDictionary: request.headersDictionary)

        guard let responseStub = matchedStub else {
            historyStorage.append((request: historyRequest, response: NetworkStubResponse.error(.notFoundError)))
            return nil
        }

        historyStorage.append((request: historyRequest, response: responseStub.response))
        return responseStub
    }
}

// MARK: - Nested Types

private extension BaseNetworkMocker {
    struct HistoryHttpRequest: HttpRequestProtocol {
        let url: String
        let query: [String: String]
        let bodyJson: JSON?
        let httpMethod: NetworkStubMethod
        let headersDictionary: [String: String]
    }
}
