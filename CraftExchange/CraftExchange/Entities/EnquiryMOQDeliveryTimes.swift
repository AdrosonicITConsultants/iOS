//
//  EnquiryMOQDeliveryTimes.swift
//  CraftExchange
//
//  Created by Kalyan on 18/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class EnquiryMOQDeliveryTimes: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var days: Int = 0
     @objc dynamic var entityID: Int = 0
    @objc dynamic var deliveryDesc: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case days = "days"
        case deliveryDesc = "deliveryDesc"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
         days = try (values.decodeIfPresent(Int.self, forKey: .days) ?? 0)
        deliveryDesc = try values.decodeIfPresent(String.self, forKey: .deliveryDesc)
    }
}

