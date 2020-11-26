//
//  Chat+Request.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Conversation {
    
    public static func getConversation(enquiryId: Int) -> Request<Data, APIError> {
      //marketingTeam/getChatMessages?enquiryId=1415
        var str = "marketingTeam/getChatMessages?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get conversation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getAdminChatEscalations(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "marketingTeam/getEscalationForAdmin?enquiryId=\(enquiryId)"
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
    
    
}
