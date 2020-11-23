//
//  Marketing.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 17/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

struct MarketingCount: Decodable {
    
    var awaitingMoq: Int?
    var awaitingMoqResponse: Int?
    var chatEscalation: Int?
    var deliveryFaultyOrder: Int?
    var enquiriesConverted: Int?
    var escaltions: Int?
    var faultyInResolution: Int?
    var incompleteAndClosedEnquiries: Int?
    var incompleteAndClosedOrders: Int?
    var ongoingEnquiries: Int?
    var ongoingOrders: Int?
    var orderCompletedSuccessfully: Int?
    var paymentsTransactions: Int?
    var totalEnquiries: Int?
    var totalOrders: Int?
    var updates: Int?
    
    enum CodingKeys: String, CodingKey {
        case awaitingMoq = "awaitingMoq"
        case awaitingMoqResponse = "awaitingMoqResponse"
        case chatEscalation = "chatEscalation"
        case deliveryFaultyOrder = "deliveryFaultyOrder"
        case enquiriesConverted = "enquiriesConverted"
        case escaltions = "escaltions"
        case faultyInResolution = "faultyInResolution"
        case incompleteAndClosedEnquiries = "incompleteAndClosedEnquiries"
        case incompleteAndClosedOrders = "incompleteAndClosedOrders"
        case ongoingEnquiries = "ongoingEnquiries"
        case ongoingOrders = "ongoingOrders"
        case orderCompletedSuccessfully = "orderCompletedSuccessfully"
        case paymentsTransactions = "paymentsTransactions"
        case totalEnquiries = "totalEnquiries"
        case totalOrders = "totalOrders"
        case updates = "updates"
    }
    
    init(awaitingMoq: Int? = nil,
         awaitingMoqResponse: Int? = nil,
         chatEscalation: Int? = nil,
         deliveryFaultyOrder: Int? = nil,
         enquiriesConverted: Int? = nil,
         escaltions: Int? = nil,
         faultyInResolution: Int? = nil,
         incompleteAndClosedEnquiries: Int? = nil,
         incompleteAndClosedOrders: Int? = nil,
         ongoingEnquiries: Int? = nil,
         ongoingOrders: Int? = nil,
         orderCompletedSuccessfully: Int? = nil,
         paymentsTransactions: Int? = nil,
         totalEnquiries: Int? = nil,
         totalOrders: Int? = nil,
         updates: Int? = nil) {
        
        self.awaitingMoq = awaitingMoq
        self.awaitingMoqResponse = awaitingMoqResponse
        self.chatEscalation = chatEscalation
        self.deliveryFaultyOrder = deliveryFaultyOrder
        self.enquiriesConverted = enquiriesConverted
        self.escaltions = escaltions
        self.faultyInResolution = faultyInResolution
        self.incompleteAndClosedEnquiries = incompleteAndClosedEnquiries
        self.incompleteAndClosedOrders = incompleteAndClosedOrders
        self.ongoingEnquiries = ongoingEnquiries
        self.ongoingOrders = ongoingOrders
        self.orderCompletedSuccessfully = orderCompletedSuccessfully
        self.paymentsTransactions = paymentsTransactions
        self.totalEnquiries = totalEnquiries
        self.totalOrders = totalOrders
        self.updates = updates
    }
    
}
