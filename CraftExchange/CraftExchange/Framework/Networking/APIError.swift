//
//  Error.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 14/01/2017.
//  Copyright © 2017 ReactiveKit. All rights reserved.
//

import Foundation

public struct APIError: Error {
  public let message: String

  public init(message: String) {
    self.message = message
  }
}

extension APIError {

  init(data: Data) {
    if let error = try? JSONDecoder().decode(GraphError.self, from: data) {
        message = error.error.code
    } else {
        message = String(data: data, encoding: .utf8) ?? "Unknown Error"
    }
  }
}

extension APIError {

  public var localizedDescription: String {
    return message
  }
}

struct GraphError: Codable {
    let error: GraphErrorClass
    enum CodingKeys: String, CodingKey {
        case error
    }
}

// MARK: - Error
struct GraphErrorClass: Codable {
    let code, message: String
    let innerError: InnerError
}

// MARK: - InnerError
struct InnerError: Codable {
    let requestID, date: String

    enum CodingKeys: String, CodingKey {
        case requestID = "request-id"
        case date
    }
}
