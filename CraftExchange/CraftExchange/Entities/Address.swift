//
//  Address.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Address: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var line1: String?
    @objc dynamic var line2: String?
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var district: String?
    @objc dynamic var state: String?
    @objc dynamic var country: String?
    @objc dynamic var pincode: String?
    @objc dynamic var landmark: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case line1 = "line1"
        case line2 = "line2"
        case street = "street"
        case city = "city"
        case district = "district"
        case state = "state"
        case country = "country"
        case pincode = "pincode"
        case landmark = "landmark"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
      line1 = try? values.decodeIfPresent(String.self, forKey: .line1)
      line2 = try? values.decodeIfPresent(String.self, forKey: .line2)
      street = try? values.decodeIfPresent(String.self, forKey: .street)
      city = try? values.decodeIfPresent(String.self, forKey: .city)
      district = try? values.decodeIfPresent(String.self, forKey: .district)
      state = try? values.decodeIfPresent(String.self, forKey: .state)
      country = try? values.decodeIfPresent(String.self, forKey: .country)
      pincode = try? values.decodeIfPresent(String.self, forKey: .pincode)
      landmark = try? values.decodeIfPresent(String.self, forKey: .landmark)
    }
}
