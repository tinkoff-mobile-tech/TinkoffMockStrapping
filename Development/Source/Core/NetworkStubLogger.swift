//
//  MockNetworkLogger.swift
//  TinkoffMockStrapping
//
//  Created by v.rudnevskiy on 30.12.2020.
//

import Foundation
import SwiftyJSON

public final class ConsoleMockNetworkLogger: NetworkStubLoggerProtocol {

    private let name: String
    private var plch: String { String(repeating: " ", count: name.count) }
    private let separator: String = String(repeating: "-", count: 100)

    public init?(name: String? = nil) {
        self.name = name ?? String(reflecting: Self.self)

        let isStubLoggerEnabled = ProcessInfo.processInfo
            .environment[ProcessInfo.isMockNetworkLoggerEnabled] != String(false)
        guard isStubLoggerEnabled else { return nil }
    }

    public func startProcessing(theRequest request: HttpRequestProtocol) {
        start()
        print("""
        \(name): Processing request with the URL: '\(request.url)'
        \(plch)  and the query: '\(request.query)'
        \(plch)  and body: '\(String(describing: request.bodyJson?.rawString()))'
        """)
    }

    public func notFound(stubForRequest request: HttpRequestProtocol) {
        print("""
        \(name): Unable to find a stub for the request with the URL: '\(request.url)'
        \(plch)  and the query: '\(request.query)'
        """)
        end()
    }

    public func jsonResponseFound() {
        print("\(name): Stub found! It's a successful response with a json payload.")
        end()
    }

    public func dataResponseFound() {
        print("\(name): Stub found! It's a successful response with a data payload.")
        end()
    }

    public func errorResponseFound(withJSONPayload flag: Bool) {
        print("\(name): Stub found! It's an error response with\(flag ? "" : "out") a json payload.")
        end()
    }

    public func connectionErrorResponseFound() {
        print("\(name): Stub found! But it's a connection error. Failing...")
        end()
    }

    private func start() {
        print()
        print(separator)
    }

    private func end() {
        print(separator)
        print()
    }
}

fileprivate extension ProcessInfo {

    static let isMockNetworkLoggerEnabled = "IS_MOCK_NETWORK_LOGGER_ENABLED"
}
