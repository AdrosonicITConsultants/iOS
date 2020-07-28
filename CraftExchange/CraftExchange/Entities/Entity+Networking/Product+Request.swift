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
            resource: {print(String(data: $0, encoding: .utf8) ?? "get all artisan product failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
      }
    
    public static func getAllProducts() -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getAllProducts",
          method: .get,
          headers: headers,
          resource: {
            print(String(data: $0, encoding: .utf8) ?? "get all products failed")
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
    
    public static func getAllProducts(clusterId: Int) -> Request<[Product], APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getClusterProducts/\(clusterId)",
          method: .get,
          headers: headers,
          resource: {
//            print(String(data: $0, encoding: .utf8) ?? "get all products failed")
//            return $0
            
            if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
              if let obj = json["data"] as? [String: Any] {
                if let prodArray = obj["products"] as? [[String: Any]] {
                  if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                      if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                          return object
                      }
                  }
                }
              }
            }
            return []
          },
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getAllProducts(productCategoryId: Int) -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getProductCategoryProducts/\(productCategoryId)",
          method: .get,
          headers: headers,
          resource: {
            print(String(data: $0, encoding: .utf8) ?? "get all products failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getAllProducts(artisanId: Int) -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getProductByArtisan/\(artisanId)",
          method: .get,
          headers: headers,
          resource: {
            print(String(data: $0, encoding: .utf8) ?? "get all products failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
}
