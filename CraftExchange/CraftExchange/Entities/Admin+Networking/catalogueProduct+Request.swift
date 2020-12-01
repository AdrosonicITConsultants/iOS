//
//  catalogueProduct+Request.swift
//  CraftExchange
//
//  Created by Kalyan on 20/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension CatalogueProduct {
    
    public static func getAllCatalogueProducts() -> Request<Data, APIError> {
      //
        let clusterId: Int? = nil
        let availability: Int? = nil
        let statusId: Int? = nil
        
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "marketingTeam/getArtisanProducts/\(clusterId)/\(availability)/\(statusId)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get all artisan product failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getCatalogueProducts(parameters: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/v1/getArtisanProducts",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "get Artisan Products failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getCatalogueProductsCount(parameters: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/v1/getArtisanProductsCount",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "get Artisan Products Count failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }

}

extension SelectArtisanBrand {
    
    public static func getAllArtisans() -> Request<Data, APIError> {
      // marketingTeam/getFilteredArtisans?clusterId=0
        let clusterId: Int = 0
        
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "marketingTeam/getFilteredArtisans?clusterId=\(clusterId)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get all artisan failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }

}
  
