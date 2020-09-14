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
        var str = "enquiry/ifEnquiryExists/\(prodId)/\(isCustom)"
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
        var str = "enquiry/generateEnquiry/\(productId)/\(isCustom)/IOS"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "generateEnquiry failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getEnquiryStages() -> Request<Data, APIError> {
        var str = "enquiry/getAllEnquiryStages"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getOpenEnquiries() -> Request<Data, APIError> {
        var str = "enquiry/getOpenEnquiries"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getOpenEnquiryDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getEnquiry/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getClosedEnquiries() -> Request<Data, APIError> {
        var str = "enquiry/getClosedEnquiries"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getClosedEnquiryDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getClosedEnquiry/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
