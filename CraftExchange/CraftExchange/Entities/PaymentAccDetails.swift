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
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var AccNoUpiMobile: String?
    @objc dynamic var name: String?
    @objc dynamic var bankName: String?
    @objc dynamic var branchName: String?
    @objc dynamic var ifsc: String?
    @objc dynamic var accType: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case AccNoUpiMobile = "accNo_UPI_Mobile"
        case name = "name"
        case bankName = "bankName"
        case branchName = "branch"
        case ifsc = "ifsc"
        case accType = "accountType"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        AccNoUpiMobile = try? values.decodeIfPresent(String.self, forKey: .AccNoUpiMobile)
        name = try? values.decodeIfPresent(String.self, forKey: .name)
        bankName = try? values.decodeIfPresent(String.self, forKey: .bankName)
        branchName = try? values.decodeIfPresent(String.self, forKey: .branchName)
        ifsc = try? values.decodeIfPresent(String.self, forKey: .ifsc)
        if let list = try? values.decodeIfPresent(AccountType.self, forKey: .accType) {
            accType = list.entityID
        }
    }
}

