//
//  PaymentStatus.swift
//  CraftExchange
//
//  Created by Kiran Songire on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class PaymentStatus: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var pid:  Int = 0
    @objc dynamic var invoiceId: Int = 0
    @objc dynamic var percentage: Int = 0
    @objc dynamic var paidAmount: Int = 0
    @objc dynamic var totalAmount: Int = 0
    @objc dynamic var receivedOn: String?
    @objc dynamic var rejectedOn: String?
    @objc dynamic var status: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case enquiryId = "enquiryId"
        case pid = "pid"
        case invoiceId = "invoiceId"
        case percentage = "percentage"
        case paidAmount = "paidAmount"
        case totalAmount = "totalAmount"
        case receivedOn = "receivedOn"
        case rejectedOn = "rejectedOn"
        case status = "status"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        type = try (values.decodeIfPresent(Int.self, forKey: .type) ?? 0)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        pid = try (values.decodeIfPresent(Int.self, forKey: .pid) ?? 0)
        invoiceId = try (values.decodeIfPresent(Int.self, forKey: .invoiceId) ?? 0)
        percentage = try (values.decodeIfPresent(Int.self, forKey: .percentage) ?? 0)
        paidAmount = try (values.decodeIfPresent(Int.self, forKey: .paidAmount) ?? 0)
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        receivedOn = try? values.decodeIfPresent(String.self, forKey: .receivedOn)
        rejectedOn = try? values.decodeIfPresent(String.self, forKey: .rejectedOn)
        status = try (values.decodeIfPresent(Int.self, forKey: .status) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
    }
}
