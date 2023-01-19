//
//  HTTPBody.swift
//  TinkoffMockStrapping
//
//  Created by Margarita Shishkina on 12.01.2023.
//

import Foundation
import SwiftyJSON

/// Тело запроса
/// Http body
public enum HttpBodyStub {

    /// В формате json
    /// JSON body
    case json(JSON)

    /// Тело запроса в любом формате
    /// Raw data
    case data(Data)
}
