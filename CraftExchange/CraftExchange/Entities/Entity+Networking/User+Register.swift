//
//  User+Register.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension User {
  public static func sendVerificationOTP(username: String) -> Request<Data, APIError> {
      return Request(
          path: "register/sendVerifyEmailOtp?email=\(username)",
          method: .get,
          resource: { print(String(data: $0, encoding: .utf8) ?? "opt sendind failed")
          return $0
      },
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func verifyEmailOTPforReg(emailId: String, otp: String) -> Request<Data, APIError> {
    let parameters: [String: Any] = ["email":emailId,
                                     "id": 0,
                                     "otp":otp]
      return Request(
          path: "register/verifyEmailOtp",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "opt verification failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func validateWeaverId(weaverId: String) -> Request<Data, APIError> {
      let parameters: [String: Any] = ["weaverId":weaverId,
                                     "id": 0]
      return Request(
          path: "register/verifyWeaverDetails",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "weaver id verification failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func registerUser(json: [String: Any],imageData: Data?) -> Request<Data, APIError> {
    var str = json.jsonString
    str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    if let content = imageData  {
        let boundary = "\(UUID().uuidString)"
        let dataLength = content.count
        let headers: [String: String] = ["Content-Type": "multipart/form-data; boundary=\(boundary)",
                                         "accept": "application/json",
                                         "Content-Length": String(dataLength)
        ]
        var queryParam = "brandLogo"
        if json["refRoleId"] as? Int == 1 {
            queryParam = "profilePic"
        }
        let finalData = MultipartDataHelper().createBody(boundary: boundary, data: content, mimeType: "application/octet-stream", filename: queryParam, param: queryParam)
        return Request(
          path: "register/user?registerRequest=\(str)",
            method: .post,
            parameters: DataParameter(finalData),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "user registration failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    let headers: [String: String] = ["accept": "application/json"]
      return Request(
        path: "register/user?registerRequest=\(str)",
          method: .post,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "user registration failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
}


