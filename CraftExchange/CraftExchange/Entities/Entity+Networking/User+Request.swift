//
//  User+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 28/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension User {
  public static func validateUsername(username: String) -> Request<Data, APIError> {
      return Request(
          path: "login/validateusername?emailOrMobile=\(username)",
          method: .get,
          resource: { print(String(data: $0, encoding: .utf8) ?? "validation failed")
          return $0
      },
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func authenticate(username: String, password: String) -> Request<Data, APIError> {
    let parameters: [String: Any] = ["emailOrMobile":username,
                                     "password":password]
      return Request(
          path: "login/authenticate",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "authentication failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
}
