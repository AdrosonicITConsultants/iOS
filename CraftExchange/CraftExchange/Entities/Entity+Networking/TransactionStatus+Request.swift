//
//  TransactionStatus+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension TransactionStatus {
    
    public static func getTransactionStatus() ->
        Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "transaction/getTransactionStatus",
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get all TransactionStatus failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
}
