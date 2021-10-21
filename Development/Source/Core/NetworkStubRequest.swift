//
//  NetworkStubRequest.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 03.09.2020.
//

import Foundation
import SwiftyJSON

/// Описывает запрос, который следует подменить, включая параметры этого запроса.
/// Network stub request
public struct NetworkStubRequest: HttpRequestProtocol, Equatable {

    /// Url запроса для подмены.
    /// Url
    public let url: String

    /// Query-параметры запроса.
    /// Query-params
    public let query: [String: String]

    /// Query-параметры, которых точно нет в запросе.
    /// Query-params parameters that are definitely not in the request
    public let excludedQuery: [String: String?]

    /// HTTP-метод запроса
    /// Http-method
    public let httpMethod: NetworkStubMethod

    /// Body-параметр запроса
    /// Body-params
    public var bodyJson: JSON?

    public init(url: String,
                query: [String: String] = [:],
                excludedQuery: [String: String?] = [:],
                httpMethod: NetworkStubMethod = .ANY,
                bodyJson: JSON? = nil) {

        self.url = url
        self.query = query
        self.excludedQuery = excludedQuery
        self.httpMethod = httpMethod
        self.bodyJson = bodyJson
    }
}

// MARK: - Extensions

public extension NetworkStubRequest {

    /// Gets the value indicates whether the stub is matched to the request.
    /// - Parameter request: The HTTP request to checking.
    /// - Complexity: O(n*m) where `n` is a count of the stub query params, `m` is a count of the request query params.
    func matches(to request: HttpRequestProtocol) -> Bool {
        guard url == request.url || request.url == "/\(url)",
            httpMethod == request.httpMethod || httpMethod == .ANY else { return false }

        let isQueryMatched = query.allSatisfy { args in
            request.query.contains { key, value in args.key == key && args.value == value }
        }

        var isExcludedQueryContained = false
        excludedQuery.forEach { argKey, argValue in
            let result: Bool

            if let argValue = argValue {
                result = request.query.contains { key, value in argKey == key && argValue == value }
            } else {
                result = request.query.contains { key, _ in argKey == key }
            }

            isExcludedQueryContained = isExcludedQueryContained || result
        }

        return isQueryMatched && !isExcludedQueryContained
    }
}
