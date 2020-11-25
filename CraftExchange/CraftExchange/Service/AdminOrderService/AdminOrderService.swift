//
//  AdminOrderService.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminOrderService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchOrders(parameter:[String: Any]) -> SafeSignal<Data> {
        return AdminOrder.getAdminOrders(parameters: parameter).response(using: client).debug()
    }
    
    func fetchIncompleteClosedOrders(parameter:[String: Any]) -> SafeSignal<Data> {
        return AdminOrder.getAdminIncompleteClosedOrders(parameters: parameter).response(using: client).debug()
    }
}
