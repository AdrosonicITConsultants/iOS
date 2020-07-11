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

    @objc dynamic var entityID: Int = 0
    dynamic var userId: Int?
    dynamic var productCategoryId: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "userId"
        case productCategoryId = "productCategoryId"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
      userId = try? values.decodeIfPresent(Int.self, forKey: .userId)
      productCategoryId = try? values.decodeIfPresent(Int.self, forKey: .productCategoryId)
    }
}
