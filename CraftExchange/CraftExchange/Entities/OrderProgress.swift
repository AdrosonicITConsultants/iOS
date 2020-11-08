//
//  OrderProgress.swift
//  CraftExchange
//
//  Created by Kalyan on 04/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class OrderProgress: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var isFaulty: Int = 0
    @objc dynamic var isResolved: Int = 0
    @objc dynamic var isAutoClosed: Int = 0
    @objc dynamic var buyerReviewComment: String?
    @objc dynamic var artisanReviewComment: String?
    @objc dynamic var artisanReviewId: String?
    @objc dynamic var buyerReviewId: String?
    @objc dynamic var orderDispatchDate: String?
    @objc dynamic var orderReceiveDate: String?
    @objc dynamic var orderCompleteDate: String?
    @objc dynamic var orderDeliveryDate: String?
    @objc dynamic var faultyMarkedOn: String?
    @objc dynamic var isRefundReceived: Int = 0
    @objc dynamic var isProductReturned: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    @objc dynamic var eta: String?
    @objc dynamic var isPartialRefundReceived: Int = 0
    @objc dynamic var partialRefundInitializedOn: String?
    @objc dynamic var partialRefundReceivedOn: String?
   
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case isFaulty = "isFaulty"
        case isResolved = "isResolved"
        case isAutoClosed = "isAutoClosed"
        case buyerReviewComment = "buyerReviewComment"
        case artisanReviewComment = "artisanReviewComment"
        case artisanReviewId = "artisanReviewId"
        case buyerReviewId = "buyerReviewId"
        case orderDispatchDate = "orderDispatchDate"
        case orderReceiveDate = "orderReceiveDate"
        case orderCompleteDate = "orderCompleteDate"
        case orderDeliveryDate = "orderDeliveryDate"
        case faultyMarkedOn = "faultyMarkedOn"
        case isRefundReceived = "isRefundReceived"
        case isProductReturned = "isProductReturned"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
        case eta = "eta"
        case isPartialRefundReceived = "isPartialRefundReceived"
        case partialRefundInitializedOn = "partialRefundInitializedOn"
        case partialRefundReceivedOn = "partialRefundReceivedOn"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        isFaulty = try (values.decodeIfPresent(Int.self, forKey: .isFaulty) ?? 0)
        isResolved = try (values.decodeIfPresent(Int.self, forKey: .isResolved) ?? 0)
        isAutoClosed = try (values.decodeIfPresent(Int.self, forKey: .isAutoClosed) ?? 0)
        buyerReviewComment = try? values.decodeIfPresent(String.self, forKey: .buyerReviewComment)
        artisanReviewComment = try? values.decodeIfPresent(String.self, forKey: .artisanReviewComment)
        artisanReviewId = try? values.decodeIfPresent(String.self, forKey: .artisanReviewId)
        buyerReviewId = try? values.decodeIfPresent(String.self, forKey: .buyerReviewId)
        orderDispatchDate = try? values.decodeIfPresent(String.self, forKey: .orderDispatchDate)
        orderReceiveDate = try? values.decodeIfPresent(String.self, forKey: .orderReceiveDate)
        orderCompleteDate = try? values.decodeIfPresent(String.self, forKey: .orderCompleteDate)
        orderDeliveryDate = try? values.decodeIfPresent(String.self, forKey: .orderDeliveryDate)
        faultyMarkedOn = try? values.decodeIfPresent(String.self, forKey: .faultyMarkedOn)
        isRefundReceived = try (values.decodeIfPresent(Int.self, forKey: .isRefundReceived) ?? 0)
        isProductReturned = try (values.decodeIfPresent(Int.self, forKey: .isProductReturned) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
        eta = try? values.decodeIfPresent(String.self, forKey: .eta)
        isPartialRefundReceived = try (values.decodeIfPresent(Int.self, forKey: .isPartialRefundReceived) ?? 0)
        partialRefundInitializedOn = try? values.decodeIfPresent(String.self, forKey: .partialRefundInitializedOn)
        partialRefundReceivedOn = try? values.decodeIfPresent(String.self, forKey: .partialRefundReceivedOn)
    }
}



