//
//  MockNetworkHistoryProtocol.swift
//  TinkoffMockStrapping
//
//  Created by v.rudnevskiy on 19.02.2021.
//

import Foundation

/// Представляет свойство и набор методов для хранения истории сетевых запросов.
/// Network history protocol
public protocol MockNetworkHistoryProtocol {

    /// Хранилище записанных сетевых запросов и соответствующих им ответов.
    /// Stubs history
    var history: [(request: HttpRequestProtocol, response: NetworkStubResponse)] { get }

    /// Очищает историю запросов.
    /// Clears stubs history
    func clearHistory()

    /// Проверяет, был ли выполнен запрос по указанному URL с указанными параметрами.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    /// Returns `true` if the request with `url` was invoked
    /// - Parameters:
    ///   - url: url
    ///   - query: request query params
    func wasInvoked(url: String, query: [String: String]) -> Bool

    /// Проверяет, сколько раз был выполнен запрос по указанному URL с указанными параметрами.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    /// Returns the number of times request with `url` was invoked
    /// - Parameters:
    ///   - url: url
    ///   - query: request query params
    func invokedTimes(url: String, query: [String: String]) -> Int
}

public extension MockNetworkHistoryProtocol {

    /// Хранилище записанных сетевых запросов без ответов
    /// Requests history without responses
    var requestsHistory: [HttpRequestProtocol] {
        history.map { $0.0 }
    }
}
