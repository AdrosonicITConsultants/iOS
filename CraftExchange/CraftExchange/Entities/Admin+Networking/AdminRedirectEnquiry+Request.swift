//
//  AdminRedirectEnquiry+Request.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka


extension AdminRedirectEnquiry {
    
    public static func getCustomRedirectEnquiries(pageNo: Int, sortBy: String, sortType: String ) -> Request<Data, APIError> {
        
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "marketingTeam/getAdminIncomingEnquiries?pageNo=\(pageNo)&sortBy=\(sortBy)&sortType=\(sortType)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get redirect enquries failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getFaultyRedirectEnquiries(pageNo: Int, sortBy: String, sortType: String ) -> Request<Data, APIError> {
        
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "marketingTeam/getAdminFaultyIncomingEnquiries?pageNo=\(pageNo)&sortBy=\(sortBy)&sortType=\(sortType)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get redirect enquries failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getOtherRedirectEnquiries(pageNo: Int, sortBy: String, sortType: String ) -> Request<Data, APIError> {
        
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "marketingTeam/getAdminOtherIncomingEnquiries?pageNo=\(pageNo)&sortBy=\(sortBy)&sortType=\(sortType)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get redirect enquries failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getLessThanEightRatingArtisans(clusterId: Int, searchString: String?, enquiryId: Int ) -> Request<Data, APIError> {
        
        var str = ""
        if searchString != ""{
            str = "marketingTeam/getArtisansLessThan8Rating?clusterId=\(clusterId)&searchString=\(searchString ?? "")&enquiryId=\(enquiryId)"
           
        }else{
            str = "marketingTeam/getArtisansLessThan8Rating?clusterId=\(clusterId)&enquiryId=\(enquiryId)"
        }
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: str,
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get redirect enquries failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func sendCustomEnquiry(enquiryId: Int, userIds: String) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId, "userIds":userIds]
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "marketingTeam/sendCustomEnquiry/\(userIds)/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "sending faulty review failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }

}
