//
//  QualityCheck+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension QualityCheck {
    static func getAllQCQuestions() -> Request<Data, APIError> {
        var str = "qc/getAllQuestions"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getAllQCStages() -> Request<Data, APIError> {
        var str = "qc/getStages"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getArtisanQcResponse(enquiryId: Int) -> Request<Data, APIError> {
        var str = "qc/getArtisanQcResponse?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getBuyerQcResponse(enquiryId: Int) -> Request<Data, APIError> {
        var str = "qc/getBuyerQcResponse?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func sendOrSaveQcForm(parameters: [String: Any] ) -> Request<Data, APIError> {
        return Request(
            path: "qc/sendOrSaveQcForm",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "sendOrSaveQcForm failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
