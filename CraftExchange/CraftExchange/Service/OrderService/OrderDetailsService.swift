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
    
    func getChangeRequestDetails(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.getChangeRequestForArtisan(eqId: enquiryId).response(using: client).debug()
    }
    
    func getOldPIDetails(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.getOldPIData(eqId: enquiryId).response(using: client).debug()
    }
    
    func sendBuyerFaultyReview(orderId: Int, buyerComment: String, multiCheck: String) -> SafeSignal<Data> {
        return Order.sendBuyerFaultyReview(orderId: orderId, buyerComment: buyerComment, multiCheck: multiCheck).response(using: client).debug()
    }
    
    func sendArtisanReview(orderId: Int, artisanReviewComment: String, multiCheck: String) -> SafeSignal<Data> {
        return Order.sendArtisanReview(orderId: orderId, artisanReviewComment: artisanReviewComment, multiCheck: multiCheck).response(using: client).debug()
    }
    
    func getOrderProgress(enquiryId: Int) -> SafeSignal<Data> {
        return Order.getOrderProgress(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func recreateOrder(orderId: Int) -> SafeSignal<Data> {
        return Order.recreateOrder(orderId: orderId).response(using: client).debug()
    }
    
    func orderDispatchAfterRecreation(orderId: Int) -> SafeSignal<Data> {
        return Order.orderDispatchAfterRecreation(orderId: orderId).response(using: client).debug()
    }
    
    func markConcernResolved(orderId: Int) -> SafeSignal<Data> {
        return Order.markConcernResolved(orderId: orderId).response(using: client).debug()
    }
}
