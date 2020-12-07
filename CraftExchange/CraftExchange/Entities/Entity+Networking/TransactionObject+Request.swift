//
//  TransactionObject+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension TransactionObject {
    
    public static func getAllOngoingTransaction() -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "transaction/getOngoingTransaction/{searchString}/{paymentType}?paymentType=0"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "getOngoingTransaction failed")
                return $0
        },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getAllTransactionForEnquiry(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "transaction/getTransactions/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "getOngoingTransaction failed")
                return $0
        },
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
