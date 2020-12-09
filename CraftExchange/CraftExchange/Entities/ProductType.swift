//
//  ProductType.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ProductType: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var productDesc: String?
    @objc dynamic var productCategoryId: Int = 0
    var productLengths = List<ProductLength>()
    var productWidths = List<ProductWidth>()
    var relatedProductTypes = List<ProductType>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productDesc = "productDesc"
        case productCategoryId = "productCategoryId"
        case productLengths = "productLengths"
        case productWidths = "productWidths"
        case relatedProductType = "relatedProductType"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        productDesc = try? values.decodeIfPresent(String.self, forKey: .productDesc)
        productCategoryId = try (values.decodeIfPresent(Int.self, forKey: .productCategoryId) ?? 0)
        if let list = try? values.decodeIfPresent([ProductLength].self, forKey: .productLengths) {
            productLengths.append(objectsIn: list)
        }
        if let list = try? values.decodeIfPresent([ProductWidth].self, forKey: .productWidths) {
            productWidths.append(objectsIn: list)
        }
        if let list = try? values.decodeIfPresent([ProductType].self, forKey: .relatedProductType) {
            relatedProductTypes.append(objectsIn: list)
        }
    }
}

