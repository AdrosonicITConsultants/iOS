//
//  UserProductCategory.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class UserProductCategory: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var userId: Int = 0
    @objc dynamic var productCategoryId: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "userId"
        case productCategoryId = "productCategoryId"
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        userId = try (values.decodeIfPresent(Int.self, forKey: .userId) ?? 0)
        productCategoryId = try (values.decodeIfPresent(Int.self, forKey: .productCategoryId) ?? 0)
    }
}
