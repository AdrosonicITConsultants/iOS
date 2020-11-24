//
//  AdminEnquiry+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension AdminEnquiry {
    public static func getAdminEnquiries(parameters: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/getAdminEnquiries",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getAdminEnquiries failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getAdminIncompleteClosedEnquiries(parameters: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/getAdminIncompletedAndClosedEnquiries",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getAdminEnquiries failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
