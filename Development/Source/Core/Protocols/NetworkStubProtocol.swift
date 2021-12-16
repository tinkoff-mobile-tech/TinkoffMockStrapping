//
//  NetworkStubProtocol.swift
//  TinkoffMockStrapping
//
//  Created by n.kuznetsov on 20.10.2021.
//

/// Протокол стаба сетевого запроса.
/// Представляет собой описание запроса и информацию об ответе на этот запрос.
/// Network stub protocol
/// Interface to describe any network stub with request and response
public protocol NetworkStubProtocol: AnyObject {

    /// Возвращает описание запроса для подмены.
    var request: NetworkStubRequest { get }

    /// Возвращает ответ, которым должен подменен запрос.
    var response: NetworkStubResponse { get set }

    /// Delay for stub
    var delay: TimeInterval { get }
}
