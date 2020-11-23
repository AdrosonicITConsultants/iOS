//
//  MarketingEnquiryAndOrderCount+Request.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 22/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension MarketingCount {

    public static func getAdminEnquiryAndOrder() -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "marketingTeam/getAdminEnquiryAndOrder"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "getAdminEnquiryAndOrder failed")
                return $0
        },
            error: APIError.init,
            needsAuthorization: false
        )
      }
}
