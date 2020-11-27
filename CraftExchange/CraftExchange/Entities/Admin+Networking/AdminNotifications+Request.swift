//
//  AdminNotification+Request.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension AdminNotifications {
    
    public static func getAllAdminNotifications() ->
        Request<Data, APIError> {
            
            let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
            return Request(
                path: "notification/getAllAdminNotifications",
                method: .get,
                headers: headers,
                resource: {print(String(data: $0, encoding: .utf8) ?? "get all AdminNotifications failed")
                    
                    return $0},
                error: APIError.init,
                needsAuthorization: true
            )
    }
    
    public static func saveDeviceToken(deviceId: String, token: String) -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "user/saveDeviceToken/\(deviceId)/iOS/\(token)",
          method: .post,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "failed to save notification token")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
}


