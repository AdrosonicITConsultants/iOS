//
//  ClusterDetails+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension ClusterDetails {
    
    public static func getAllClusters() -> Request<[ClusterDetails], APIError> {
        return Request(
            path: "cluster/getAllClusters",
            method: .get,
            resource: { print(String(data: $0, encoding: .utf8) ?? "cluster fetch failed")
                if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        let object = try JSONDecoder().decode([ClusterDetails].self, from: data)
                        return object
                    }
                }
                return []
        },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getProductsForCluster(clusterId:Int) -> Request<[ClusterDetails], APIError> {
        return Request(
            path: "cluster/getProductCategories/\(clusterId)",
            method: .get,
            resource: { print(String(data: $0, encoding: .utf8) ?? "cluster product details fetch failed")
                if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        let object = try JSONDecoder().decode([ClusterDetails].self, from: data)
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
