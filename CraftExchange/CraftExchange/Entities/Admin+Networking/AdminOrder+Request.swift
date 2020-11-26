//
//  AdminOrder+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension AdminOrder {
    public static func getAdminOrders(parameters: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/getAdminOrders",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getAdminEnquiries failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getAdminIncompleteClosedOrders(parameters: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/getAdminIncompletedAndClosedOrders",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getAdminEnquiries failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
