//
//  OrderListService.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class OrderListService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getOngoingOrders() -> SafeSignal<Data> {
        return Order.getOpenOrders().response(using: client).debug()
    }
    
    func getClosedOrders() -> SafeSignal<Data> {
        return Order.getClosedOrders().response(using: client).debug()
    }
    
}
