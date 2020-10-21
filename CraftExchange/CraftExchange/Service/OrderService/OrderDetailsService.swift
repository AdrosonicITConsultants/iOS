//
//  OrderDetailsService.swift
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

class OrderDetailsService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    
    func getOpenOrderDetails(enquiryId: Int) -> SafeSignal<Data> {
        return Order.getOpenOrderDetails(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getClosedOrderDetails(enquiryId: Int) -> SafeSignal<Data> {
        return Order.getClosedOrderDetails(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func toggleChangeRequest(enquiryId: Int, isEnabled: Int) -> SafeSignal<Data> {
        return Enquiry.toggleChangeRequest(enquiryId: enquiryId, isEnabled: isEnabled).response(using: client).debug()
    }
}
