//
//  ProductWidth.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ProductWidth: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var width: String?
    @objc dynamic var productTypeId: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case productTypeId = "productTypeId"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        width = try? values.decodeIfPresent(String.self, forKey: .width)
        productTypeId = try (values.decodeIfPresent(Int.self, forKey: .productTypeId) ?? 0)
    }
}