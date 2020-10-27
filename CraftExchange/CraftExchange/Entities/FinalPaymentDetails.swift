//
//  FinalPaymentDetails.swift
//  CraftExchange
//
//  Created by Kalyan on 27/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FinalPaymentDetails: Object, Decodable {
    @objc dynamic var pid:  Int = 0
    @objc dynamic var invoiceId: Int = 0
    @objc dynamic var payableAmount: Int = 0
    @objc dynamic var totalAmount: Int = 0
    @objc dynamic var finalPaymentDone = false

    enum CodingKeys: String, CodingKey {
        case pid = "pid"
        case invoiceId = "invoiceId"
        case payableAmount = "payableAmount"
        case totalAmount = "totalAmount"
        case finalPaymentDone = "finalPaymentDone"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        pid = try (values.decodeIfPresent(Int.self, forKey: .pid) ?? 0)
        invoiceId = try (values.decodeIfPresent(Int.self, forKey: .invoiceId) ?? 0)
        payableAmount = try (values.decodeIfPresent(Int.self, forKey: .payableAmount) ?? 0)
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        finalPaymentDone = try(values.decodeIfPresent(Bool.self, forKey: .finalPaymentDone) ?? false)
            }
}

