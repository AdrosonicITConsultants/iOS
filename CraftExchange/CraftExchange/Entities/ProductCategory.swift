//
//  ProductCategory.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ProductCategory: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var prodCatDescription: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case prodCatDescription = "productDesc"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
      prodCatDescription = try values.decodeIfPresent(String.self, forKey: .prodCatDescription)
    }
}
