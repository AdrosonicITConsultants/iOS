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

class AdminNotificationService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getAllTheNotifications() -> SafeSignal<Data> {
        return AdminNotifications.getAllAdminNotifications().response(using: client).debug()
    }
}
