//
//  Enquiry+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Enquiry {
    
    static func checkIfEnquiryExists(for prodId: Int, isCustom: Bool) -> Request<Data, APIError> {
        var str = "enquiry/ifEnquiryExists/{productId}/{isCustom}?productId=\(prodId)&isCustom=\(isCustom)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func generateEnquiry(productId: Int, isCustom: Bool) -> Request<Data, APIError> {
      let parameters: [String: Any] = ["productId":productId,
                                       "isCustom": isCustom,
                                       "deviceName":"IOS"]
        return Request(
            path: "enquiry/generateEnquiry/{productId}/{isCustom}/{deviceName}",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "generateEnquiry failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
