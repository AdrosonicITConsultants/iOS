//
//  Product+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension Product {
  
    public static func getAllArtisanProduct() -> Request<Data, APIError> {
        //
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "product/getArtitionProducts",
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get profile failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
      }
    
    
    static func fetchProductImage(with productId: Int, imageName: String) -> Request<Data, APIError> {
        var str = "Product/\(productId)/\(imageName)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,//"Product/10/download.jpg",//
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
