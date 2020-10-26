//
//  Enquiry+ChangeRequest.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Enquiry {
    public static func toggleChangeRequest(enquiryId: Int, isEnabled: Int) -> Request<Data, APIError> {
        var str = "enquiry/toggleChangeRequestFromArtisan?enquiryId=\(enquiryId)&status=\(isEnabled)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .post,
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "toggleChangeRequestFromArtisan failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getChangeRequestMetadata() -> Request<[ChangeRequestType], APIError> {
      return Request(
          path: "enquiry/getChangeRequestItemTable",
          method: .get,
          resource: { print(String(data: $0, encoding: .utf8) ?? "ChangeRequest fetch failed")
            if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
              if let array = json["data"] as? [[String: Any]] {
                  let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                  let object = try JSONDecoder().decode([ChangeRequestType].self, from: data)
                  return object
              }
            }
            return []
      },
          error: APIError.init,
          needsAuthorization: false
      )
    }
    
    public static func raiseChangeRequest(crJson: [String: Any]) -> Request<Data, APIError> {
        return Request(
            path: "enquiry/changeRequest",
            method: .post,
            parameters: JSONParameters(crJson),
            resource: {print(String(data: $0, encoding: .utf8) ?? "raiseChangeRequest failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
