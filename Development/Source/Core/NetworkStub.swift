//
//  NetworkStub.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 24.08.2020.
//

import Foundation
import SwiftyJSON

/// Представляет псевдоним для замыкания модификации JSON-а.
/// Typealias for json modifier
public typealias JsonModifier = ((NetworkStubProtocol) -> Void)

/// Базовая реализация стаба сетевого запроса.
/// Network stub implementation
open class NetworkStub: NetworkStubProtocol {

    // MARK: State

    public let request: NetworkStubRequest
    public var response: NetworkStubResponse

    // MARK: Lifecycle

    public required init(request: NetworkStubRequest, response: NetworkStubResponse) {
        self.request = request
        self.response = response
    }
}

// MARK: - Factories

public extension NetworkStub {

    /// Возвращает обычный успешный стаб.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    ///   - excludedQuery: Параметры, которых точно нет в запросе.
    ///   - jsonFileName: Имя файла с содержимым ответа.
    ///   - bundle: Бандл, в котором содержится указанный файл.
    ///   - jsonModifier: Функция, модифицирующая стаб.
    /// Returns success stub
    /// - Parameters:
    ///   - url: url
    ///   - query: query-params
    ///   - excludedQuery: Query-params parameters that are definitely not in the request
    ///   - jsonFileName: Filename with response
    ///   - bundle: Bundle in which `jsonFileName` is located
    ///   - jsonModifier: Json-modifier closure
    static func `default`<Stub: NetworkStub>(url: String,
                                             query: [String: String] = [:],
                                             excludedQuery: [String: String?] = [:],
                                             jsonFileName: String,
                                             bundle: Bundle? = nil,
                                             jsonModifier: JsonModifier? = nil) -> Stub {

        let json = NetworkStub.readJSON(jsonFileName: jsonFileName, bundle: bundle ?? Bundle(for: Self.self))

        let request = NetworkStubRequest(url: url, query: query, excludedQuery: excludedQuery)
        let stub = Stub(request: request, response: .json(json))

        jsonModifier?(stub)

        return stub
    }

    /// Возвращает стаб с ошибкой соединения.
    /// - Warning: Ошибка не совместима с UI-тестами, потому в среде UI-тестов использование
    ///            этой ошибки приведет к неудачному завершению теста.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    ///   - excludedQuery: Параметры, которых точно нет в запросе.
    /// Returns network error stub
    /// - Warning: doesn't work in UI Tests
    /// - Parameters:
    ///   - url: url
    ///   - query: query-params
    ///   - excludedQuery: Query-params parameters that are definitely not in the request
    static func connectionError<Stub: NetworkStub>(url: String,
                                                   query: [String: String] = [:],
                                                   excludedQuery: [String: String?] = [:]) -> Stub {

        let request = NetworkStubRequest(url: url, query: query, excludedQuery: excludedQuery)
        let stub = Stub(request: request, response: .connectionError)

        return stub
    }

    /// Возвращает стаб с ошибкой.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    ///   - excludedQuery: Параметры, которых точно нет в запросе.
    ///   - error: Ошибка.
    ///   - jsonModifier: Функция, модифицирующая стаб.
    /// Returns error stub
    /// - Parameters:
    ///   - url: url
    ///   - query: query-params
    ///   - excludedQuery: Query-params parameters that are definitely not in the request
    ///   - error: error
    ///   - jsonModifier: Json-modifier closure
    static func error<Stub: NetworkStub>(url: String,
                                         query: [String: String] = [:],
                                         excludedQuery: [String: String?] = [:],
                                         error: NetworkStubError,
                                         jsonModifier: JsonModifier? = nil) -> Stub {

        let request = NetworkStubRequest(url: url, query: query, excludedQuery: excludedQuery)
        let stub = Stub(request: request, response: .error(error))
        jsonModifier?(stub)

        return stub
    }

    /// Возвращает модификацию существующего стаба.
    /// - Parameters:
    ///   - stub: Существующий стаб для модификации.
    ///   - jsonModifier: Функция, модифицирующая стаб.
    /// Returns the modification of the existing stub
    /// - Parameters:
    ///   - stub: Existing stub
    ///   - jsonModifier: Json-modifier closure
    static func modifyExisting<Stub: NetworkStub>(stub: Stub, jsonModifier: JsonModifier) -> Stub {
        jsonModifier(stub)
        return stub
    }
}

// MARK: - NetworkStubProtocol Extension

public extension NetworkStubProtocol {

    /// JSON для подмены ответа на текущий запрос.
    /// JSON
    var json: JSON {
        get {
            switch response {
            case let .json(json):
                return json
            case let .error(error):
                return error.json ?? JSON([:])
            default:
                return JSON([:])
            }
        }
        set {
            switch response {
            case .json:
                response = .json(newValue)
            case let .error(error):
                response = .error(NetworkStubError(json: newValue, code: error.code, reasonPhrase: error.reasonPhrase))
            default:
                return
            }
        }
    }
}

// MARK: - Utils

public extension NetworkStub {

    /// Читает JSON из файла.
    /// - Parameters:
    ///   - jsonFileName: имя требуемого файла (без расширения).
    ///   - bundle: бандл требуемого файла (значение по умолчанию — nil (бандл пода)).
    /// Reads Json from file
    /// - Parameters:
    ///   - jsonFileName: file name (without type)
    ///   - bundle: Bundle in which `jsonFileName` is located (without type)
    static func readJSON(jsonFileName: String, bundle: Bundle? = nil) -> JSON {
        let reader = FileReader(defaultBundle: bundle ?? Bundle(for: Self.self))
        let data = reader.readFile(name: jsonFileName, extension: "json")

        var json = JSON([:])
        do {
            json = try JSON(data: data)
        } catch {
            fatalError(error.localizedDescription)
        }

        return json
    }
}
