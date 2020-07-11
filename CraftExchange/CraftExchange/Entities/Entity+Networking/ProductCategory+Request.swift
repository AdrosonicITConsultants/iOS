//
//  ProductCategory+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension ProductCategory {
  
public static func getAllProducts() -> Request<Data, APIError> {
    return Request(
        path: "product/getAllProducts",
        method: .get,
        resource: { print(String(data: $0, encoding: .utf8) ?? "products fetch failed")
//          if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
//            if let array = json["data"] as? [[String: Any]] {
//                let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
//                let object = try JSONDecoder().decode([ProductCategory].self, from: data)
//                return object
//            }
//          }
//          return []
            return $0
    },
        error: APIError.init,
        needsAuthorization: false
    )
  }
}
