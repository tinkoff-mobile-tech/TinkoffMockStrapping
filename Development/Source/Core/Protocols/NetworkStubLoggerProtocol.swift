//
//  NetworkStubLoggerProtocol.swift
//  TinkoffMockStrapping
//
//  Created by n.kuznetsov on 20.10.2021.
//

/// Содержит набор методов для логгирования работы мокера.
/// Log server protocol
public protocol NetworkStubLoggerProtocol {

    /// Инициализирует логгер.
    /// - Parameter name: подпись мокера.
    /// - Returns: Опциональный экземпляр логгера.
    /// Initializer
    /// - Parameter name: mockers name
    /// - Returns: logger
    init?(name: String?)

    /// Метод для логгирования начала обрабоки запроса.
    /// - Parameter request: запрос, поступивший на обработку.
    /// Starts request logging
    /// - Parameter request: request for logging
    func startProcessing(theRequest request: HttpRequestProtocol)

    /// Метод для логгирования незастабанного запроса.
    /// - Parameter request: запрос, поступивший на обработку.
    /// Logs unstubbed request
    /// - Parameter request: request for logging
    func notFound(stubForRequest request: HttpRequestProtocol)

    /// Метод для логгирования застабанного запроса с нагрузкой в виде JSON.
    /// Logs responses with json
    func jsonResponseFound()

    /// Метод для логгирования застабанного запроса с нагрузкой в виде Data.
    /// Logs responses with any data
    func dataResponseFound()

    /// Метод для логгирования застабанного запроса с ошибкой.
    /// - Parameter flag: указана ли в ответе нагрузка в виде JSON.
    /// Logs error responses
    /// - Parameter flag: does the error-response contain json?
    func errorResponseFound(withJSONPayload flag: Bool)

    /// Метод для логгирования застабанного запроса с ошибкой соедения.
    /// Logs network-error responses
    func connectionErrorResponseFound()
}
