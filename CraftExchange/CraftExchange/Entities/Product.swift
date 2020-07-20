//
//  Product.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Product: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var productSpec: String?
    @objc dynamic var code: String?
    @objc dynamic var warpYarnId: Int = 0
    @objc dynamic var weftYarnId: Int = 0
    @objc dynamic var extraWeftYarnId: Int = 0
    @objc dynamic var warpYarnCount: String?
    @objc dynamic var weftYarnCount: String?
    @objc dynamic var extraWeftYarnCount: String?
    @objc dynamic var warpDyeId: Int = 0
    @objc dynamic var weftDyeId: Int = 0
    @objc dynamic var extraWeftDyeId: Int = 0
    @objc dynamic var length: String?
    @objc dynamic var width: String?
    dynamic var reedCountId: Int?
    dynamic var productStatusId: Int?
    @objc dynamic var gsm: String?
    @objc dynamic var weight: String?
    @objc dynamic var createdOn: Date?
    @objc dynamic var modifiedOn: Date?
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var artitionId: Int = 0
    @objc dynamic var productCategoryId: Int = 0
    var relatedProducts = List<Product>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productSpec = "productSpec"
        case code = "code"
        case warpYarnId = "warpYarnId"
        case weftYarnId = "weftYarnId"
        case extraWeftYarnId = "extraWeftYarnId"
        case warpYarnCount = "warpYarnCount"
        case weftYarnCount = "weftYarnCount"
        case extraWeftYarnCount = "extraWeftYarnCount"
        case warpDyeId = "warpDyeId"
        case weftDyeId = "weftDyeId"
        case extraWeftDyeId = "extraWeftDyeId"
        case length = "length"
        case width = "width"
        case reedCountId = "reedCountId"
        case productStatusId = "productStatusId"
        case gsm = "gsm"
        case weight = "weight"
        case createdOn = "created_on"
        case modifiedOn = "modified_on"
        case artitionId = "artitionId"
        case isDeleted = "isDeleted"
        case relProduct = "relProduct"
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
        productCategoryId = try (values.decodeIfPresent(Int.self, forKey: .productCategoryId) ?? 0)
        productSpec = try values.decodeIfPresent(String.self, forKey: .productSpec)
        code = try? values.decodeIfPresent(String.self, forKey: .code)
        warpYarnId = try (values.decodeIfPresent(Int.self, forKey: .warpYarnId) ?? 0)
        weftYarnId = try (values.decodeIfPresent(Int.self, forKey: .weftYarnId) ?? 0)
        extraWeftYarnId = try (values.decodeIfPresent(Int.self, forKey: .extraWeftYarnId) ?? 0)
        warpDyeId = try (values.decodeIfPresent(Int.self, forKey: .warpDyeId) ?? 0)
        weftDyeId = try (values.decodeIfPresent(Int.self, forKey: .weftDyeId) ?? 0)
        extraWeftDyeId = try (values.decodeIfPresent(Int.self, forKey: .extraWeftDyeId) ?? 0)
        warpYarnCount = try? values.decodeIfPresent(String.self, forKey: .warpYarnCount)
        weftYarnCount = try? values.decodeIfPresent(String.self, forKey: .weftYarnCount)
        extraWeftYarnCount = try? values.decodeIfPresent(String.self, forKey: .extraWeftYarnCount)
        length = try? values.decodeIfPresent(String.self, forKey: .length)
        width = try? values.decodeIfPresent(String.self, forKey: .width)
        reedCountId = try? values.decodeIfPresent(Int.self, forKey: .reedCountId)
        productStatusId = try? values.decodeIfPresent(Int.self, forKey: .productStatusId)
        gsm = try? values.decodeIfPresent(String.self, forKey: .gsm)
        weight = try? values.decodeIfPresent(String.self, forKey: .weight)
        createdOn = try? values.decodeIfPresent(Date.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(Date.self, forKey: .modifiedOn)
        artitionId = try (values.decodeIfPresent(Int.self, forKey: .artitionId) ?? 0)
        if let value = try? values.decodeIfPresent(Int.self, forKey: .artitionId) {
            artitionId = value
        } else {
            artitionId = KeychainManager.standard.userID ?? 0
        }
        if let value = try? values.decodeIfPresent(Bool.self, forKey: .isDeleted) {
            isDeleted = value
        } else if let value = try? values.decodeIfPresent(String.self, forKey: .isDeleted) {
            isDeleted = value.boolValue
        } else {
            isDeleted = false
        }
//        if let list = try? values.decodeIfPresent(Product.self, forKey: .relProduct) {
//           relatedProducts.append(list)
//        }
    }
}
