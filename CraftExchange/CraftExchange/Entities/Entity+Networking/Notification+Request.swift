//
//  Notification+Request.swift
//  CraftExchange
//
//  Created by Kalyan on 03/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension Notifications {
    
    public static func getAllNotifications() ->
        Request<Data, APIError> {
            
            let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
            return Request(
                path: "notification/getAllNotifications",
                method: .get,
                headers: headers,
                resource: {print(String(data: $0, encoding: .utf8) ?? "get all notifications failed")
                    
                    return $0},
                error: APIError.init,
                needsAuthorization: true
            )
    }
    
    public static func markAsReadNotification(withId: Int) -> Request<Data, APIError> {
        //
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "notification/markAsRead/\(withId)",
            method: .post,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "failed to mark as read the notification")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func markAsAllReadNotification() -> Request<Data, APIError> {
        
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "notification/markAllAsRead",
            method: .post,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "failed to mark as all read the notification")
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


