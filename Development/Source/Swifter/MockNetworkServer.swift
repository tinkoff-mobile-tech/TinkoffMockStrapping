//
//  MockNetworkServer.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 31.07.2020.
//

import Foundation
import Swifter
import SwiftyJSON

/// Cервер для подмены ответов на сетевые запросы в среде UI тестов
/// Mock-server for UI tests
public final class MockNetworkServer: BaseNetworkMocker {

    private let port: in_port_t

    /// Значение порта, при котором будет найден случайный свободный порт
    /// This value let the server to choose any free port by itself
    public static let autoselectedPort: in_port_t = 0

    /// Сервер для мокирования
    /// Mock server based on Swifter
    public private(set) var server: HttpServer?

    /// Инициализирует класс сервера.
    /// Initializer
    public init(port: UInt16 = autoselectedPort,
                logger: NetworkStubLoggerProtocol? = ConsoleMockNetworkLogger(name: "MockNetworkServer")) {
        self.port = port
        super.init(logger: logger)
    }

    /// Функция для установки стаба
    /// Stub setter
    public override func setStub(_ stub: NetworkStubProtocol) {
        guard let httpServer = server else {
            fatalError("Couldn't set the stub because the server didn't start.")
        }

        super.setStub(stub)

        let response: ((HttpRequest) -> HttpResponse) = { [weak self] request in
            guard let self = self else {
                fatalError("Server didn't start")
            }
            sleep(stub.delay)
            return self.getResponse(request: request)
        }

        switch stub.request.httpMethod {
        case .GET:
            httpServer.GET[stub.request.url] = response
        case .POST:
            httpServer.POST[stub.request.url] = response
        case .PUT:
            httpServer.PUT[stub.request.url] = response
        case .DELETE:
            httpServer.DELETE[stub.request.url] = response
        case .PATCH:
            httpServer.PATCH[stub.request.url] = response
        case .HEAD:
            httpServer.HEAD[stub.request.url] = response
        case .ANY:
            httpServer[stub.request.url] = response
        }
    }
}

// MARK: - Server Management API

extension MockNetworkServer: MockNetworkServerProtocol {

    /// Запускает сервер подмены ответов на сетевые запросы.
    /// - Returns: Порт, на котором запущен сервер или `nil`, если не удалось запустить сервер или получить номер порта.
    /// Starts the server
    /// - Returns: Port number where server is started or `nil` if server has not started or selected port is not available
    public func start() -> UInt16? {
        guard server == nil else {
            fatalError("Attempted to start the server when it already started.")
        }

        server = HttpServer()
        start(server: server, on: port)

        server?.notFoundHandler = { _ in
            .notFound
        }

        guard let port = try? server?.port() else {
            return nil
        }

        return UInt16(port)
    }

    /// Останавливает сервер подмены ответов на сетевые запросы и удаляет все стабы.
    /// Stops the server and removes all stubs
    public func stop() {
        guard server != nil else {
            fatalError("Attempted to stop the server when it not started.")
        }

        server?.stop()
        removeAllStubs()
        server = nil
    }

    // MARK: Private

    private func start(server: HttpServer?, on port: in_port_t) {
        do {
            try server?.start(port)
        } catch {
            fatalError("Couldn't start the mock network server. \n\(String(describing: error))")
        }
    }
}

// MARK: - Private API

private extension MockNetworkServer {

    /// Выполняет обработку содержимого стаба с ошибкой и возвращает HTTP-ответ.
    /// - Parameter error: Описание ошибки.
    /// - Returns: Возвращает HTTP-ответ с кодом, причиной и содержимым из описания ошибки.
    /// Processes error-stub and returns http-response
    /// - Parameter error: Error description
    /// - Returns: http-response with error-code, reason and error description content
    func process(error: NetworkStubError) -> HttpResponse {
        if let data = error.json?.rawData() {
            return .raw(error.code, error.reasonPhrase, ["Content-Type": "application/json"], { try? $0.write(data) })
        } else {
            return .raw(error.code, error.reasonPhrase, nil, nil)
        }
    }

    /// Выполняет обработку содержимого успешного стаба и возвращает HTTP-ответ.
    /// - Parameter data: Содержимое ответа.
    /// - Parameter contentType: Тип содержимого (Content-Type).
    /// - Returns: Возвращает ответ HTTP 200 OK.
    /// Processes success-stub and returns http-response
    /// - Parameter data: response content
    /// - Parameter contentType: Content-Type
    /// - Returns: http-response 200 OK
    func process(data: Data, contentType: String) -> HttpResponse {
        return .raw(200, "OK", ["Content-Type": contentType], { try? $0.write(data) })
    }

    /// Выполняет обработку содержимого успешного стаба и возвращает HTTP-ответ.
    /// - Parameter json: Содержимое ответа.
    /// - Returns: Возвращает ответ HTTP 200 OK.
    /// Processes success-stub and returns http-response
    /// - Parameter json: response content
    /// - Returns: http-response 200 OK
    func process(json: JSON) -> HttpResponse {
        guard let data = json.rawData() else {
            return .internalServerError
        }

        return process(data: data, contentType: "application/json")
    }

    func getResponse(request: HttpRequest) -> HttpResponse {
        logger?.startProcessing(theRequest: request)

        guard let responseStub = getResponseStub(for: request) else {
            logger?.notFound(stubForRequest: request)
            return .notFound
        }

        switch responseStub.response {
        case let .json(json):
            logger?.jsonResponseFound()
            return process(json: json)

        case let .data(data, type):
            logger?.dataResponseFound()
            return process(data: data, contentType: type)

        case let .error(error):
            logger?.errorResponseFound(withJSONPayload: error.json != nil)
            return process(error: error)

        case .connectionError:
            logger?.connectionErrorResponseFound()
            fatalError("ATTENTION! " +
                "The `\(String(describing: responseStub.response))` " +
                "does not supported in the UI tests.")
        }
    }
}

// MARK: - HttpRequest Extension

extension HttpRequest: HttpRequestProtocol {

    public var url: String {
        path
    }

    public var httpMethod: NetworkStubMethod {
        NetworkStubMethod(rawValue: method) ?? NetworkStubMethod.ANY
    }

    public var query: [String: String] {
        Dictionary(queryParams, uniquingKeysWith: { _, last in last })
    }

    public var bodyJson: JSON? {
        try? JSON(data: Data(body))
    }
}

// MARK: - JSON Extension

fileprivate extension JSON {

    /// Converts JSON to a raw Data.
    func rawData() -> Data? {
        guard let jsonString = self.rawString(),
            let data = jsonString.data(using: .utf8) else {
            fatalError("Could not get a raw JSON string.")
        }

        return data
    }
}

// MARK: - Internal

func sleep(_ delay: TimeInterval) {
    usleep(useconds_t(delay * 1_000_000))
}
