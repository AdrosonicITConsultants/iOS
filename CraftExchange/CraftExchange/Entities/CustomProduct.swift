//
//  CustomProduct.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CustomProduct: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var productSpec: String?
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
    @objc dynamic var reedCountId: Int = 0
    @objc dynamic var gsm: String?
    @objc dynamic var createdOn: Date?
    @objc dynamic var modifiedOn: Date?
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var buyerId: Int = 0
    @objc dynamic var productCategoryId: Int = 0
    @objc dynamic var productTypeId: Int = 0
    var relatedProducts = List<Product>()
    var weaves = List<CustomWeaveType>()
    var productImages = List<CustomProductImage>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productSpec = "product_spec"
        case warpYarnId = "warpYarn"
        case weftYarnId = "weftYarn"
        case extraWeftYarnId = "extraWeftYarn"
        case warpYarnCount = "warpYarnCount"
        case weftYarnCount = "weftYarnCount"
        case extraWeftYarnCount = "extraWeftYarnCount"
        case warpDyeId = "warpDye"
        case weftDyeId = "weftDye"
        case extraWeftDyeId = "extraWeftDye"
        case length = "length"
        case width = "width"
        case reedCountId = "reedCount"
        case gsm = "gsm"
        case createdOn = "createdOn"
        case modifiedOn = "modified_on"
        case buyerId = "buyerId"
        case isDeleted = "isDeleted"
        case relProduct = "relProduct"
        case productTypeId = "productType"
        case productImages = "productImages"
        case productCategory = "productCategory"
        case productWeaves = "productWeaves"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        if let obj = try? values.decodeIfPresent(ProductType.self, forKey: .productTypeId) {
            productTypeId = obj.entityID
        }
        productSpec = try? values.decodeIfPresent(String.self, forKey: .productSpec)
        if let obj = try? values.decodeIfPresent(Yarn.self, forKey: .warpYarnId) {
            warpYarnId = obj.entityID
        }
        if let obj = try? values.decodeIfPresent(Yarn.self, forKey: .weftYarnId) {
            weftYarnId = obj.entityID
        }
        if let obj = try? values.decodeIfPresent(Yarn.self, forKey: .extraWeftYarnId) {
            extraWeftYarnId = obj.entityID
        }
        if let obj = try? values.decodeIfPresent(Dye.self, forKey: .warpDyeId) {
            warpDyeId = obj.entityID
        }
        if let obj = try? values.decodeIfPresent(Dye.self, forKey: .weftDyeId) {
            weftDyeId = obj.entityID
        }
        if let obj = try? values.decodeIfPresent(Dye.self, forKey: .extraWeftDyeId) {
            extraWeftDyeId = obj.entityID
        }
        warpYarnCount = try? values.decodeIfPresent(String.self, forKey: .warpYarnCount)
        weftYarnCount = try? values.decodeIfPresent(String.self, forKey: .weftYarnCount)
        extraWeftYarnCount = try? values.decodeIfPresent(String.self, forKey: .extraWeftYarnCount)
        length = try? values.decodeIfPresent(String.self, forKey: .length)
        width = try? values.decodeIfPresent(String.self, forKey: .width)
        if let obj = try? values.decodeIfPresent(ReedCount.self, forKey: .reedCountId) {
            reedCountId = obj.entityID
        }
        gsm = try? values.decodeIfPresent(String.self, forKey: .gsm)
        createdOn = try? values.decodeIfPresent(Date.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(Date.self, forKey: .modifiedOn)
        buyerId = try (values.decodeIfPresent(Int.self, forKey: .buyerId) ?? 0)
        if let value = try? values.decodeIfPresent(Int.self, forKey: .buyerId) {
            buyerId = value
        } else if let value = try? values.decodeIfPresent(String.self, forKey: .buyerId) {
            buyerId = Int(value) ?? 0
        } else {
            buyerId = 0
        }
        if let value = try? values.decodeIfPresent(Bool.self, forKey: .isDeleted) {
            isDeleted = value
        } else if let value = try? values.decodeIfPresent(String.self, forKey: .isDeleted) {
            isDeleted = value.boolValue
        } else {
            isDeleted = false
        }
        if let list = try? values.decodeIfPresent([Product].self, forKey: .relProduct) {
           relatedProducts.append(objectsIn: list)
        }
        if let list = try? values.decodeIfPresent([CustomProductImage].self, forKey: .productImages) {
           productImages.append(objectsIn: list)
        }
        if let list = try? values.decodeIfPresent(ProductCategory.self, forKey: .productCategory) {
            productCategoryId = list.entityID
        }
        if let list = try? values.decodeIfPresent([CustomWeaveType].self, forKey: .productWeaves) {
            weaves.append(objectsIn:list)
        }
    }
}
