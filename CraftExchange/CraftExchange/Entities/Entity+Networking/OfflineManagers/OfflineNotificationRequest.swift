//
//  OfflineNotificationRequest.swift
//  CraftExchange
//
//  Created by Kalyan on 14/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import ReactiveKit

enum NotificationActionType: String {
    case markAsReadNotification
    case markAsAllReadNotification
}

class OfflineNotificationRequest: NSObject, OfflineRequest {
    
    var completion: ((Error?) -> Void)?
    let request: Request<Data, APIError>
    let type: NotificationActionType
    let notificationId: Int?
    
    /// Initializer with an arbitrary number to demonstrate data persistence
    ///
    /// - Parameter identifier: arbitrary number
    init(type: NotificationActionType, notificationId: Int?) {
        self.type = type
        self.notificationId = notificationId
        
        switch type {
        case .markAsReadNotification:
            self.request = Notifications.markAsReadNotification(withId: notificationId ?? 0)
            
        case .markAsAllReadNotification:
            self.request = Notifications.markAsAllReadNotification()
        }
        super.init()
    }
    
    /// Dictionary methods are optional for simple use cases, but required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String : Any]) {
        guard let type = dictionary["type"] as? NotificationActionType else { return  nil }
        guard let notificationId = dictionary["notificationId"] as? Int else { return  nil }
        self.init(type: type, notificationId: notificationId)
    }
    
    var dictionaryRepresentation: [String : Any]? {
        return ["type" : type.rawValue, "notificationId" : notificationId ?? 0]
    }
    
    func perform(completion: @escaping (Error?) -> Void) {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            let error = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            completion(error)
            return
        }
        client.unsafeResponse(for: request).observe(with: { (response) in
            if self.type == .markAsReadNotification && response.error == nil {
                DispatchQueue.main.async {
                    Notifications.notificationIsDeleteTrue(forId: self.notificationId ?? 0)
                    Notifications.deleteAllNotificationsWithIsDeleteTrue()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "markAsReadNotificationUpdate"), object: nil)
                }
            }else if self.type == .markAsAllReadNotification && response.error == nil {
                DispatchQueue.main.async {
                    Notifications.setAllNotificationIsDeleteTrue()
                    Notifications.deleteAllNotificationsWithIsDeleteTrue()
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "markAsAllReadNotificationUpdate"), object: nil)
                }
            }
            completion(response.error)
        }).dispose(in: self.bag)
    }
}
