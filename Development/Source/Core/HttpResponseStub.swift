//
//  HTTPResponse.swift
//  TinkoffMockStrapping
//
//  Created by Margarita Shishkina on 12.01.2023.
//

import Foundation
import SwiftyJSON

/// Http ответ
/// Http response
public struct HttpResponseStub: HttpResponseStubProtocol {

    /// Статус код
    /// Status code
    public let statusCode: Int

    /// Статус
    /// Reason phrase
    public let reasonPhrase: String

    /// Заголовки
    /// Headers
    public let headers: [String: String]

    /// Тело ответа
    /// Response body
    public let body: HttpBodyStub

    /// Инициализатор
    /// Initializer
    public init(statusCode: Int = 200,
                reasonPhrase: String = "OK",
                headers: [String: String] = [:],
                body: HttpBodyStub = .json(JSON())) {
        self.statusCode = statusCode
        self.reasonPhrase = reasonPhrase
        self.headers = headers
        self.body = body
    }
}
