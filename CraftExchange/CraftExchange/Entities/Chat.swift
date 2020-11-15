//
//  Chat.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Chat: Object, Decodable {
    
    @objc dynamic var id: String = ""
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var entityID: Int = 0
    @objc dynamic var isOld: Bool = false
    @objc dynamic var productTypeId: String?
    @objc dynamic var buyerId: Int = 0
    @objc dynamic var orderReceiveDate: String?
    @objc dynamic var lastChatDate: String?
    @objc dynamic var enquiryGeneratedOn: String?
    @objc dynamic var convertedToOrderDate: String?
    @objc dynamic var unreadMessage: Int = 0
    @objc dynamic var escalation: Int = 0
    @objc dynamic var orderStatus: String?
    @objc dynamic var lastUpdatedOn: String?
    @objc dynamic var orderStatusId: Int = 0
    @objc dynamic var changeRequestDone: Int = 0
    @objc dynamic var enquiryOpenOrClosed: Int = 0
    @objc dynamic var orderAmount: String?
    @objc dynamic var buyerCompanyName: String?
    @objc dynamic var buyerLogo: String?
    @objc dynamic var enquiryNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case enquiryId = "enquiryId"
        case productTypeId = "productTypeId"
        case buyerId = "buyerId"
        case orderReceiveDate = "orderReceiveDate"
        case lastChatDate = "lastChatDate"
        case enquiryGeneratedOn = "enquiryGeneratedOn"
        case convertedToOrderDate = "convertedToOrderDate"
        case unreadMessage = "unreadMessage"
        case escalation = "escalation"
        case orderStatus = "orderStatus"
        case lastUpdatedOn = "lastUpdatedOn"
        case orderStatusId = "orderStatusId"
        case changeRequestDone = "changeRequestDone"
        case enquiryOpenOrClosed = "enquiryOpenOrClosed"
        case orderAmount = "orderAmount"
        case buyerCompanyName = "buyerCompanyName"
        case buyerLogo = "buyerLogo"
        case enquiryNumber = "enquiryNumber"
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        id = "\(entityID)"
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        productTypeId = try? values.decodeIfPresent(String.self, forKey: .productTypeId)
        buyerId = try (values.decodeIfPresent(Int.self, forKey: .buyerId) ?? 0)
        orderReceiveDate = try? values.decodeIfPresent(String.self, forKey: .orderReceiveDate)
        lastChatDate = try? values.decodeIfPresent(String.self, forKey: .lastChatDate)
        enquiryGeneratedOn = try? values.decodeIfPresent(String.self, forKey: .enquiryGeneratedOn)
        convertedToOrderDate = try? values.decodeIfPresent(String.self, forKey: .convertedToOrderDate)
        unreadMessage = try (values.decodeIfPresent(Int.self, forKey: .unreadMessage) ?? 0)
        escalation = try (values.decodeIfPresent(Int.self, forKey: .escalation) ?? 0)
        orderStatus = try? values.decodeIfPresent(String.self, forKey: .orderStatus)
        lastUpdatedOn = try? values.decodeIfPresent(String.self, forKey: .lastUpdatedOn)
        orderStatusId = try (values.decodeIfPresent(Int.self, forKey: .orderStatusId) ?? 0)
        changeRequestDone = try (values.decodeIfPresent(Int.self, forKey: .changeRequestDone) ?? 0)
        enquiryOpenOrClosed = try (values.decodeIfPresent(Int.self, forKey: .enquiryOpenOrClosed) ?? 0)
        orderAmount = try? values.decodeIfPresent(String.self, forKey: .orderAmount)
        buyerCompanyName = try? values.decodeIfPresent(String.self, forKey: .buyerCompanyName)
        buyerLogo = try? values.decodeIfPresent(String.self, forKey: .buyerLogo)
        enquiryNumber = try? values.decodeIfPresent(String.self, forKey: .enquiryNumber)
        
    }
}
