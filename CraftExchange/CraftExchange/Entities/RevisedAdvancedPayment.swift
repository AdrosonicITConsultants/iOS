//
//  RevisedAdvancedPayment.swift
//  CraftExchange
//
//  Created by Kalyan on 14/12/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RevisedAdvancedPayment: Object, Decodable {
    @objc dynamic var piId: Int = 0
    @objc dynamic var percentage: Int = 0
    @objc dynamic var paidAmount: Int = 0
    @objc dynamic var totalAmount: Int = 0
    @objc dynamic var pendingAmount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case piId = "piId"
        case percentage = "percentage"
        case paidAmount = "paidAmount"
        case totalAmount = "totalAmount"
        case pendingAmount = "pendingAmount"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        piId = try (values.decodeIfPresent(Int.self, forKey: .piId) ?? 0)
        percentage = try (values.decodeIfPresent(Int.self, forKey: .percentage) ?? 0)
        paidAmount = try (values.decodeIfPresent(Int.self, forKey: .paidAmount) ?? 0)
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        pendingAmount = try (values.decodeIfPresent(Int.self, forKey: .pendingAmount) ?? 0)
        
    }
}

