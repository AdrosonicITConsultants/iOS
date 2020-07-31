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
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var prodCatDescription: String?
    @objc dynamic var code: String?
    var productTypes = List<ProductType>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case prodCatDescription = "productDesc"
        case code = "code"
        case productTypes = "productTypes"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        prodCatDescription = try values.decodeIfPresent(String.self, forKey: .prodCatDescription)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        if let list = try? values.decodeIfPresent([ProductType].self, forKey: .productTypes) {
           productTypes.append(objectsIn: list)
        }
    }
}
