//
//  PaymentAccDetails.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class PaymentAccDetails: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var AccNoUpiMobile: String?
    @objc dynamic var name: String?
    @objc dynamic var bankName: String?
    @objc dynamic var branchName: String?
    @objc dynamic var ifsc: String?
    dynamic var accType: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case AccNoUpiMobile = "accNoUpiMobile"
        case name = "name"
        case bankName = "bankName"
        case branchName = "branchName"
        case ifsc = "ifsc"
        case accType = "accTypeId"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        AccNoUpiMobile = try? values.decodeIfPresent(String.self, forKey: .AccNoUpiMobile)
        name = try? values.decodeIfPresent(String.self, forKey: .name)
        bankName = try? values.decodeIfPresent(String.self, forKey: .bankName)
        branchName = try? values.decodeIfPresent(String.self, forKey: .branchName)
        ifsc = try? values.decodeIfPresent(String.self, forKey: .ifsc)
        accType = try? values.decodeIfPresent(Int.self, forKey: .accType)
      
    }
}

