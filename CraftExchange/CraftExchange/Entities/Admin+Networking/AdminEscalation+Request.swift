//
//  AdminEscalation+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension AdminEscalation {
    public static func getAdminEscalations(cat: String, pageNo: Int, searchString: String) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/getAdminEscalationResponses?category=\(cat)&pageNo=\(pageNo)&sortBy=date&sortType=desc&searchStr=\(searchString)",
            method: .get,
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getAdminEscalationResponses failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getAdminEscalationsCount(cat: String, pageNo: Int, searchString: String) -> Request<Data, APIError> {
        return Request(
            path: "marketingTeam/getAdminEscalationResponsesCount?category=\(cat)&pageNo=\(pageNo)&sortBy=date&sortType=desc&searchStr=\(searchString)",
            method: .get,
            resource: {print(String(data: $0, encoding: .utf8) ?? "marketingTeam/getAdminEscalationResponsesCount failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func resolveEscalation(escalationId: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["escalationId":escalationId]
        var str = "enquiry/resolveEscalation?escalationId=\(escalationId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "chat initiation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func generateNewEnquiryFaulty(enquiryId: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "deviceName": "ios"]
        var str = "marketingTeam/createNewEnquiry?enquiryId=\(enquiryId)&deviceName=ios"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "chat initiation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
}
