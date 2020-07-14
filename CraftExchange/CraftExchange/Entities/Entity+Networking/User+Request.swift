//
//  User+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 28/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension User {
  public static func validateUsername(username: String) -> Request<Data, APIError> {
    var roleId = 1
    if let role =  KeychainManager.standard.userRoleId {
      roleId = role
    }
      return Request(
          path: "login/validateusername?emailOrMobile=\(username)&roleId=\(roleId)",
          method: .get,
          resource: { print(String(data: $0, encoding: .utf8) ?? "validation failed")
          return $0
      },
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func authenticate(username: String, password: String) -> Request<Data, APIError> {
    var roleId = 1
    if let role =  KeychainManager.standard.userRoleId {
      roleId = role
    }
    let parameters: [String: Any] = ["emailOrMobile":username,
                                     "password":password,
                                     "roleId":roleId]
      return Request(
          path: "login/authenticate",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "authentication failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func sendOTP(username: String) -> Request<Data, APIError> {
    var roleId = 1
    if let role =  KeychainManager.standard.userRoleId {
      roleId = role
    }
      return Request(
          path: "forgotpassword/sendotp?email=\(username)&roleId=\(roleId)",
          method: .get,
          resource: { print(String(data: $0, encoding: .utf8) ?? "opt sendind failed")
          return $0
      },
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func verifyEmailOtp(emailId: String, otp: String) -> Request<Data, APIError> {
    let parameters: [String: Any] = ["email":emailId,
                                     "id": 0,
                                     "otp":otp]
      return Request(
          path: "forgotpassword/verifyEmailOtp",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "opt varification failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func resetPassword(username: String, password: String) -> Request<Data, APIError> {
    var roleId = 1
    if let role =  KeychainManager.standard.userRoleId {
      roleId = role
    }
    let parameters: [String: Any] = ["emailOrMobile":username,
                                     "password":password,
                                     "roleId":roleId]
      return Request(
          path: "forgotpassword/resetpassword",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "reset password failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
    
    public static func getProfile() -> Request<Data, APIError> {
        return Request(
            path: "user/myprofile",
            method: .get,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get profile failed")
              return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func updateBuyerProfile(json: [String: Any], imageData: Data?, filename: String?) -> Request<Data, APIError> {
        var str = json.jsonString
        print("buyer: \n\n \(str)")
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let content = imageData, let filename = filename  {
            let boundary = "\(UUID().uuidString)"
            let dataLength = content.count
            let headers: [String: String] = ["Content-Type": "multipart/form-data; boundary=\(boundary)",
                                             "accept": "application/json",
                                             "Content-Length": String(dataLength)
            ]
            let finalData = MultipartDataHelper().createBody(boundary: boundary, data: content, mimeType: "application/octet-stream", filename: filename, param: "logo")
            return Request(
                path: "user/edit/buyerProfile?profileDetails=\(str)",
                method: .put,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: { $0 },
                error: APIError.init,
                needsAuthorization: true
            )
        }else {
            return Request(
              path: "user/edit/buyerProfile?profileDetails=\(str)",
                method: .put,
                resource: {print(String(data: $0, encoding: .utf8) ?? "buyer edit profile failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }
    }
    
    /*
     
     public static func updateBuyerProfile(json: [String: Any]) -> Request<Data, APIError> {
         var str = json.jsonString
         print("buyer: \n\n \(str)")
         str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
           return Request(
             path: "user/edit/buyerProfile?profileDetails=\(str)",
               method: .put,
               resource: {print(String(data: $0, encoding: .utf8) ?? "buyer edit profile failed")
                 return $0},
               error: APIError.init,
               needsAuthorization: true
           )
     }
     */
    
    public static func updateArtisanProfile(json: [String: Any]) -> Request<Data, APIError> {
      var str = json.jsonString
      str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      let headers: [String: String] = ["accept": "application/json"]
        return Request(
          path: "user/edit/artistProfile?address=\(str)",
            method: .put,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "artist edit profile failed")
              return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func updateArtisanBrandDetails(json: [String: Any]) -> Request<Data, APIError> {
        let finalJson = ["companyDetails" : json]
        var str = finalJson.jsonString
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["accept": "application/json"]
        return Request(
            path: "user/edit/artistBrandDetails?editBrandDetails=\(str)",
            method: .put,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "artist edot brand details failed")
              return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func updateArtisanBankDetails(json: [[String: Any]]) -> Request<Data, APIError> {
        var str = json.jsonString
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let parameters: [String: Any] = ["paymentAccountDetails":json]
        return Request(
          path: "user/edit/bankDetails",
            method: .put,
            parameters: JSONParameters(json),
            resource: {print(String(data: $0, encoding: .utf8) ?? "artist edot brand details failed")
              return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
}

class MultipartDataHelper {
    func createBody(boundary: String, data: Data, mimeType: String, filename: String , param: String) -> Data {
      func convertToStringToData(inputString: String) -> Data {
        let outputData = inputString.data(using: .utf8)
        return outputData ?? Data()
      }
      
      let body = NSMutableData()
      
      let boundaryPrefix = "--\(boundary)\r\n"
      let boundaryPrefixData = convertToStringToData(inputString: boundaryPrefix)
      let contentDisposition = "Content-Disposition: form-data; name=\"\(param)\"; filename=\"\(filename)\"\r\n"
      let contentDsipositionData = convertToStringToData(inputString: contentDisposition)
      
      let mimeType = "Content-Type: \(mimeType)\r\n\r\n"
      let mimeTypeData = convertToStringToData(inputString: mimeType)
      
      
      body.append(boundaryPrefixData)
      body.append(contentDsipositionData)
      body.append(mimeTypeData)
      body.append(data)
      body.append(convertToStringToData(inputString: "\r\n"))
      let bottomBoundaryStr = "--\(boundary)--"
      body.append(convertToStringToData(inputString: bottomBoundaryStr))
      
      return body as Data
    }
}
