//
//  Marketing+Request.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 17/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension AdminTeammate {

    public static func getAdminRoles() -> Request<Data, APIError> {
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      var str = "marketingTeam/getAdminRoles"
      str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      return Request(
          path: str,
          method: .get,
          headers: headers,
          resource: {
              print(String(data: $0, encoding: .utf8) ?? "getAdminRoles failed")
              return $0
      },
          error: APIError.init,
          needsAuthorization: false
      )
    }
    
    public static func getAdminProfile(userId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "marketingTeam/getAdmin?id=\(userId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
   
    public static func getAdminTeam(pageNo: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["pageNo": pageNo,
                                        "refRoleId": -1,
                                       "searchStr": ""]
        print(parameters)
        return Request(
            path: "marketingTeam/getAdmins",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "getAdmins failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
