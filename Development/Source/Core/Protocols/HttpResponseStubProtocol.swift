//
//  IHTTPResponse.swift
//  TinkoffMockStrapping
//
//  Created by Margarita Shishkina on 12.01.2023.
//

import Foundation

/// Протокол ответа сервера
/// Http response protocol
public protocol HttpResponseStubProtocol {

    /// Статус код
    /// Status code
    var statusCode: Int { get }

    /// Статус
    /// Reason phrase
    var reasonPhrase: String { get }

    /// Заголовки
    /// Headers
    var headers: [String: String] { get }

    /// Тело ответа
    /// Response body
    var body: HttpBodyStub { get }
}
