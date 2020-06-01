//
//  Address+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension Country {
  
public static func getAllCountries() -> Request<[Country], APIError> {
    return Request(
        path: "register/getAllCountries",
        method: .get,
        resource: { print(String(data: $0, encoding: .utf8) ?? "countries fetch failed")
          if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
            if let array = json["data"] as? [[String: Any]] {
                let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                let object = try JSONDecoder().decode([Country].self, from: data)
                return object
            }
          }
          return []
    },
        error: APIError.init,
        needsAuthorization: false
    )
  }
}
