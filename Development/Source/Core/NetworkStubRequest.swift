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

    /// Заголовки запроса.
    /// Headers
    public let headersDictionary: [String: String]
    
    public var regexPatternBody: String?

    public init(url: String,
                query: [String: String] = [:],
                excludedQuery: [String: String?] = [:],
                httpMethod: NetworkStubMethod = .ANY,
                bodyJson: JSON? = nil,
                headersDictionary: [String: String] = [:],
                egexPatternBody: String? = nil) {

        self.url = url
        self.query = query
        self.excludedQuery = excludedQuery
        self.httpMethod = httpMethod
        self.bodyJson = bodyJson
        self.headersDictionary = headersDictionary
        self.regexPatternBody = regexPatternBody
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

        let isHeadersDictionaryMatched = headersDictionary.allSatisfy { args in
            request.headersDictionary.contains { key, value in
                args.key == key && args.value == value
            }
        }

        let isBodyMatched: Bool = {
            guard let bodyJson = bodyJson,
                let requestBodyJson = request.bodyJson else {
                return true
            }
            guard let bodyString = bodyJson.rawString(),
                let requestBodyString = requestBodyJson.rawString(),
                let bodyDictionary = convertToDictionary(jsonString: bodyString),
                let requestBodyDictionary = convertToDictionary(jsonString: requestBodyString) else {
                return false
            }
            return bodyDictionary.allSatisfy { args in
                requestBodyDictionary.contains { key, value in
                    guard let rawValue = JSON(rawValue: args.value),
                        let requestRawValue = JSON(rawValue: value) else { return false }
                    return args.key == key && rawValue == requestRawValue
                }
            }
        }()
        
        let isBodyMatchedRegex: Bool = {
            guard let regexPatternBody = regexPatternBody,
                  let requestBodyJson = request.bodyJson,
                  let requestBodyString = requestBodyJson.rawString() else {
                return true
            }

            return doesMatchRegex(regexPattern: regexPatternBody, inputString: requestBodyString)
        }()

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

        return isQueryMatched && isHeadersDictionaryMatched &&
            isBodyMatched && !isExcludedQueryContained && isBodyMatchedRegex
    }
}

// MARK: - Helpers

private extension NetworkStubRequest {

    /// Converts JSON string to Dictionary
    /// - Parameter jsonString: a JSON string to convert to dictionary
    func convertToDictionary(jsonString: String) -> [String: Any]? {
        if let data = jsonString.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func doesMatchRegex(regexPattern: String, inputString: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let range = NSRange(inputString.startIndex..., in: inputString)
            return regex.firstMatch(in: inputString, options: [], range: range) != nil
        } catch {
            print("Ошибка при создании регулярного выражения: \(error.localizedDescription)")
            return false
        }
    }
}
