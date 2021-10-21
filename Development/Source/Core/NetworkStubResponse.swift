//
//  NetworkStubResponse.swift
//  TinkoffMockStrapping
//
//  Created by Roman Gladkikh on 03.09.2020.
//

import Foundation
import SwiftyJSON

/// Описывает ответ от сервера, на который подменяется заданный запрос.
/// Network stub response
public enum NetworkStubResponse {

    /// Успешный ответ в формате JSON.
    /// Success json response
    case json(JSON)

    /// Успешный ответ в любом формате (pdf, png, etc).
    /// Success (pdf, png, etc) response
    case data(data: Data, contentType: String = "application/data")

    /// Ответ с ошибкой.
    /// Error response
    case error(NetworkStubError)

    /// Ошибка соединения.
    /// - Warning: Ошибка не совместима с UI-тестами, потому в среде UI-тестов использование
    ///            этой ошибки приведет к неудачному завершению теста.
    /// Network error
    /// - Warning: this error doesn't work  in UI tests
    case connectionError
}
