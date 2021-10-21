//
//  NetworkStubError.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 03.09.2020.
//

import Foundation
import SwiftyJSON

/// Представляет сетевую ошибку.
/// Network stub error
public struct NetworkStubError {

    /// Возвращает json содержимое ответа.
    /// Returns json
    public let json: JSON?

    /// Возвращает код ошибки, например, 500.
    /// Returns error code
    public let code: Int

    /// Возвращает причину ошибки, например, "Internal Server Error".
    /// Returns error reason
    public let reasonPhrase: String

    /// Инициализирует новый экземпляр сетевой ошибки с HTTP-кодом, причиной и содержимым.
    /// - Parameters:
    ///   - json: Содержимое ответа.
    ///   - code: HTTP-код ошибки, например, 500.
    ///   - reasonPhrase: Причина ошибки, например, "Internal Server Error".
    /// Initializer
    /// - Parameters:
    ///   - json: Response content
    ///   - code: Http response code
    ///   - reasonPhrase: Error reason (e.g., "Internal Server Error")
    public init(json: JSON, code: Int, reasonPhrase: String) {
        self.json = json
        self.code = code
        self.reasonPhrase = reasonPhrase
    }

    /// Инициализирует новый экземпляр сетевой ошибки с HTTP-кодом и причиной без содержимого.
    /// - Parameters:
    ///   - code: HTTP-код ошибки, например, 500.
    ///   - reasonPhrase: Причина ошибки, например, "Internal Server Error".
    /// Initializer
    /// - Parameters:
    ///   - code: Http response code
    ///   - reasonPhrase: Error reason (e.g., "Internal Server Error")
    public init(code: Int, reasonPhrase: String) {
        self.json = nil
        self.code = code
        self.reasonPhrase = reasonPhrase
    }
}

// MARK: - NetworkStubError Extension

public extension NetworkStubError {

    /// Возвращает HTTP ошибку 404 Not Found без содержимого.
    static var notFoundError: NetworkStubError {
        NetworkStubError(code: 404, reasonPhrase: "Not Found")
    }

    /// Возвращает HTTP ошибку 500 Internal Server Error без содержимого.
    static var internalServerError: NetworkStubError {
        NetworkStubError(code: 500, reasonPhrase: "Internal Server Error")
    }
}

public extension NetworkStubError {

    /// Возвращает ошибку с содержимым из указанного файла с указанным HTTP-кодом и причиной ошибки.
    /// - Parameters:
    ///   - jsonFileName: Имя файла с содержимым ошибки.
    ///   - code: HTTP-код ошибки, например, 500.
    ///   - reasonPhrase: Причина ошибки, например, "Internal Server Error".
    ///   - bundle: Бандл, в котором находится указанный файл.
    static func fromJson(jsonFileName: String,
                         code: Int,
                         reasonPhrase: String,
                         bundle: Bundle? = nil) -> NetworkStubError {

        let json = NetworkStub.readJSON(jsonFileName: jsonFileName, bundle: bundle)
        return NetworkStubError(json: json, code: code, reasonPhrase: reasonPhrase)
    }
}
