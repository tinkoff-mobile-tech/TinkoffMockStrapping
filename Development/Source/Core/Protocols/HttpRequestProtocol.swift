//
//  HttpRequestProtocol.swift
//  TinkoffMockStrapping
//
//  Created by v.rudnevskiy on 19.02.2021.
//

import Foundation
import SwiftyJSON

/// Представляет поля для описания запроса.
/// Http request protocol
public protocol HttpRequestProtocol {

    /// Url запроса.
    /// url
    var url: String { get }

    /// Query-параметры запроса.
    /// Query-params
    var query: [String: String] { get }

    /// Body-параметры запроса.
    /// Body-params
    var bodyJson: JSON? { get }

    /// HTTP-метод запроса
    /// Http-method
    var httpMethod: NetworkStubMethod { get }

    /// Заголовки запроса.
    /// Headers
    var headersDictionary: [String: String] { get }
}
