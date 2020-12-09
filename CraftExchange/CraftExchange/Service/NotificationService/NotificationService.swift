//
//  BuyerNotificationService.swift
//  CraftExchange
//
//  Created by Kalyan on 02/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class NotificationService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    func getAllTheNotifications() -> SafeSignal<Data> {
        return Notifications.getAllNotifications().response(using: client).debug()
    }
    func markAsReadNotification(notificationId: Int) -> SafeSignal<Data> {
        return Notifications.markAsReadNotification(withId: notificationId).response(using: client).debug()
    }
    func markAsAllRead() -> SafeSignal<Data> {
        return Notifications.markAsAllReadNotification().response(using: client).debug()
    }
    func savePushNotificationToken(deviceId: String, token: String) -> SafeSignal<Data> {
        return Notifications.saveDeviceToken(deviceId: deviceId, token: token).response(using: client).debug()
    }
}
