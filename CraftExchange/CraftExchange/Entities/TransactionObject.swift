//
//  TransactionObject.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TransactionObject: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var challanId: Int = 0
    @objc dynamic var accomplishedStatus: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var isActionCompleted: Int = 0
    @objc dynamic var isActive: Int = 0
    @objc dynamic var completedOn: Date?
    @objc dynamic var modifiedOn: Date?
    @objc dynamic var transactionOn: Date?
    @objc dynamic var paidAmount: Int = 0
    @objc dynamic var paymentId: Int = 0
    @objc dynamic var percentage: Int = 0
    @objc dynamic var piHistoryId: Int = 0
    @objc dynamic var piId: Int = 0
    @objc dynamic var receiptId: Int = 0
    @objc dynamic var taxInvoiceId: Int = 0
    @objc dynamic var totalAmount: Int = 0
    @objc dynamic var upcomingStatus: Int = 0
    @objc dynamic var enquiryCode: String?
    @objc dynamic var orderCode: String?
    @objc dynamic var eta: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case accomplishedStatus = "accomplishedStatus"
        case challanId = "challanId"
        case completedOn = "completedOn"
        case enquiryId = "enquiryId"
        case isActionCompleted = "isActionCompleted"
        case isActive = "isActive"
        case modifiedOn = "modifiedOn"
        case paidAmount = "paidAmount"
        case paymentId = "paymentId"
        case percentage = "percentage"
        case piHistoryId = "piHistoryId"
        case piId = "piId"
        case receiptId = "receiptId"
        case taxInvoiceId = "taxInvoiceId"
        case totalAmount = "totalAmount"
        case transactionOn = "transactionOn"
        case upcomingStatus = "upcomingStatus"
        case enquiryCode = "enquiryCode"
        case orderCode = "orderCode"
        case eta = "eta"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        accomplishedStatus = try (values.decodeIfPresent(Int.self, forKey: .accomplishedStatus) ?? 0)
        challanId = try (values.decodeIfPresent(Int.self, forKey: .challanId) ?? 0)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        completedOn = try? values.decodeIfPresent(Date.self, forKey: .completedOn)
        isActionCompleted = try (values.decodeIfPresent(Int.self, forKey: .isActionCompleted) ?? 0)
        isActive = try (values.decodeIfPresent(Int.self, forKey: .isActive) ?? 0)
        modifiedOn = try? values.decodeIfPresent(Date.self, forKey: .modifiedOn)
        paidAmount = try (values.decodeIfPresent(Int.self, forKey: .paidAmount) ?? 0)
        paymentId = try (values.decodeIfPresent(Int.self, forKey: .paymentId) ?? 0)
        percentage = try (values.decodeIfPresent(Int.self, forKey: .percentage) ?? 0)
        piHistoryId = try (values.decodeIfPresent(Int.self, forKey: .piHistoryId) ?? 0)
        piId = try (values.decodeIfPresent(Int.self, forKey: .piId) ?? 0)
        receiptId = try (values.decodeIfPresent(Int.self, forKey: .receiptId) ?? 0)
        taxInvoiceId = try (values.decodeIfPresent(Int.self, forKey: .taxInvoiceId) ?? 0)
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        transactionOn = try? values.decodeIfPresent(Date.self, forKey: .transactionOn)
        upcomingStatus = try (values.decodeIfPresent(Int.self, forKey: .upcomingStatus) ?? 0)
        enquiryCode = try? values.decodeIfPresent(String.self, forKey: .enquiryCode)
        orderCode = try? values.decodeIfPresent(String.self, forKey: .orderCode)
        eta = try? values.decodeIfPresent(String.self, forKey: .eta)
    }
}


