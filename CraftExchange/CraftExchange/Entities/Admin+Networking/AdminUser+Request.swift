//
//  AdminUser+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension AdminUser {
    public static func getUsers(clusterId: Int, pageNo: Int, rating: Int, roleId: Int, searchStr: String, sortBy: String, sortType: String) -> Request<Data, APIError> {
      let parameters: [String: Any] = [ "clusterId": clusterId,
                                        "pageNo": pageNo,
                                        "rating": rating,
                                        "roleId": roleId,
                                        "searchStr": searchStr,
                                        "sortBy": sortBy,
                                        "sortType": sortType]
        return Request(
            path: "marketingTeam/getUsers",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getUsers failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
