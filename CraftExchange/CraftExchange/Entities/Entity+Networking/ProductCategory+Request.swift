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
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "product/getAllProducts",
            method: .get,
            headers: headers,
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "products fetch failed")
                return $0
        },
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
