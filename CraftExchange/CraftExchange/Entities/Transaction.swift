//
//  Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Transaction: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var totalAmount: Int = 0
    @objc dynamic var paidAmount: Int = 0
    @objc dynamic var percentage: Int = 0
    @objc dynamic var enquiryCode: String?
    @objc dynamic var orderCode: String?
    @objc dynamic var eta: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case totalAmount = "totalAmount"
        case paidAmount = "paidAmount"
        case percentage = "percentage"
        case enquiryCode = "enquiryCode"
        case orderCode = "orderCode"
        case eta = "eta"
        case transactionOngoing = "transactionOngoing"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        paidAmount = try (values.decodeIfPresent(Int.self, forKey: .paidAmount) ?? 0)
        percentage = try (values.decodeIfPresent(Int.self, forKey: .percentage) ?? 0)
        enquiryCode = try values.decodeIfPresent(String.self, forKey: .enquiryCode)
        orderCode = try values.decodeIfPresent(String.self, forKey: .orderCode)
        eta = try values.decodeIfPresent(String.self, forKey: .eta)
    }
}
