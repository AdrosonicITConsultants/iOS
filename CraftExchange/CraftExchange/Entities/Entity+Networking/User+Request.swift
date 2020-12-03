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
    let parameters: [String: Any] = ["username":username,
                                     "password":password]
      return Request(
          path: "login/authenticateMarketing",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "authentication failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
    
  public static func logout() -> Request<Data, APIError> {
    let token = UserDefaults.standard.value(forKey: "notification_token") as? String
    let parameters: [String: Any] = ["token":token ?? ""]
      return Request(
          path: "marketingTeam/logoutMobile?token=\(token ?? "")",
          method: .post,
          parameters: JSONParameters(parameters),
          resource: {print(String(data: $0, encoding: .utf8) ?? "authentication failed")
            return $0},
          error: APIError.init,
          needsAuthorization: false
      )
  }
  
  public static func sendOTP(username: String) -> Request<Data, APIError> {
      return Request(
          path: "forgotpassword/sendOtpToMarketingTeam?username=\(username)",
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
    let parameters: [String: Any] = ["username":username,
                                     "password":password]
      return Request(
          path: "forgotpassword/resetMarketingPassword",
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
    
    public static func updateArtisanProfile(json: [String: Any], imageData: Data?, filename: String?) -> Request<Data, APIError> {
      var str = json.jsonString
      str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let content = imageData, let filename = filename  {
        let boundary = "\(UUID().uuidString)"
        let dataLength = content.count
        let headers: [String: String] = ["Content-Type": "multipart/form-data; boundary=\(boundary)",
                                         "accept": "application/json",
                                         "Content-Length": String(dataLength)
        ]
        let finalData = MultipartDataHelper().createBody(boundary: boundary, data: content, mimeType: "application/octet-stream", filename: filename, param: "profilePic")
            return Request(
              path: "user/edit/artistProfile?address=\(str)",
                method: .put,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artist edit profile failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
            
        }else {
//            let headers: [String: String] = ["accept": "application/json"]
            return Request(
              path: "user/edit/artistProfile?address=\(str)",
                method: .put,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artist edit profile failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }
    }
    
    public static func updateArtisanBrandDetails(json: [String: Any], imageData: Data?, filename: String?) -> Request<Data, APIError> {
        let finalJson = json//["companyDetails" : json]
        var str = finalJson.jsonString
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
                path: "user/edit/artistBrandDetails?editBrandDetails=\(str)",
                method: .put,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artist edot brand details failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }else {
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
    
    public static func getFilteredArtisans() -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "filter/getFilteredArtisansMobile",
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get all filtered artisan failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    static func fetchBrandImage(with userID: Int, name: String) -> Request<Data, APIError> {
        var str = "User/\(userID)/CompanyDetails/Logo/\(name)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,//"Product/10/download.jpg",//
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func fetchProfileImage(with userID: Int, name: String) -> Request<Data, APIError> {
        var str = "User/\(userID)/ProfilePics/\(name)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,//"Product/10/download.jpg",//
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
}

class MultipartDataHelper {
    
    func convertToStringToData(inputString: String) -> Data {
      let outputData = inputString.data(using: .utf8)
      return outputData ?? Data()
    }
    
    func createBody(boundary: String, data: Data, mimeType: String, filename: String , param: String) -> Data {
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
    
    func createBody(boundary: String, mimeType: String, imageData: [(String, Data)]) -> Data {
      let body = NSMutableData()
        var i = 1
        for image in imageData {
            let boundaryPrefix = "--\(boundary)\r\n"
            let boundaryPrefixData = convertToStringToData(inputString: boundaryPrefix)
            let contentDisposition = "Content-Disposition: form-data; name=\"file\(i)\"; filename=\"\(image.0)\"\r\n"
            let contentDsipositionData = convertToStringToData(inputString: contentDisposition)
            
            let mimeType = "Content-Type: \(mimeType)\r\n\r\n"
            let mimeTypeData = convertToStringToData(inputString: mimeType)
            
            body.append(boundaryPrefixData)
            body.append(contentDsipositionData)
            body.append(mimeTypeData)
            body.append(image.1)
            body.append(convertToStringToData(inputString: "\r\n"))
            if image == imageData.last! {
                let bottomBoundaryStr = "--\(boundary)--"
                body.append(convertToStringToData(inputString: bottomBoundaryStr))
            }
            i = i + 1
        }
      
      return body as Data
    }
}
