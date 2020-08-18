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
    @objc dynamic var productDesc: String?
    @objc dynamic var productTag: String?
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
    @objc dynamic var reedCountId: Int = 0
    @objc dynamic var productStatusId: Int = 0
    @objc dynamic var gsm: String?
    @objc dynamic var weight: String?
    @objc dynamic var createdOn: Date?
    @objc dynamic var modifiedOn: Date?
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var artitionId: Int = 0
    @objc dynamic var productCategoryId: Int = 0
    @objc dynamic var productTypeId: Int = 0
    @objc dynamic var madeWithAnthran: Int = 0
    @objc dynamic var clusterId: Int = 0
    var relatedProducts = List<Product>()
    var weaves = List<WeaveType>()
    var productImages = List<ProductImage>()
    var productCares = List<ProductCareType>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productSpec = "productSpec"
        case productDesc = "product_spe"
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
        case productTypeId = "productTypeId"
        case madeWithAnthran = "madeWithAnthran"
        case clusterId = "clusterId"
        case productTag = "tag"
        case productImages = "productImages"
        case cluster = "cluster"
        case productCategory = "productCategory"
        case productWeaves = "productWeaves"
        case productCares = "productCares"
        case productType = "productType"
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
        productTypeId = try (values.decodeIfPresent(Int.self, forKey: .productTypeId) ?? 0)
        if let value = try? values.decodeIfPresent(Int.self, forKey: .clusterId) {
            clusterId = value
        } else if let value = try? values.decodeIfPresent(String.self, forKey: .clusterId) {
            clusterId = Int(value) ?? 0
        } else {
            clusterId = 0
        }
        madeWithAnthran = try (values.decodeIfPresent(Int.self, forKey: .madeWithAnthran) ?? 0)
        productSpec = try? values.decodeIfPresent(String.self, forKey: .productSpec)
        productDesc = try? values.decodeIfPresent(String.self, forKey: .productDesc)
        productTag = try? values.decodeIfPresent(String.self, forKey: .productTag)
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
        reedCountId = try (values.decodeIfPresent(Int.self, forKey: .reedCountId) ?? 0)
        productStatusId = try (values.decodeIfPresent(Int.self, forKey: .productStatusId) ?? 0)
        gsm = try? values.decodeIfPresent(String.self, forKey: .gsm)
        weight = try? values.decodeIfPresent(String.self, forKey: .weight)
        createdOn = try? values.decodeIfPresent(Date.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(Date.self, forKey: .modifiedOn)
        artitionId = try (values.decodeIfPresent(Int.self, forKey: .artitionId) ?? 0)
        if let value = try? values.decodeIfPresent(Int.self, forKey: .artitionId) {
            artitionId = value
        } else if let value = try? values.decodeIfPresent(String.self, forKey: .artitionId) {
            artitionId = Int(value) ?? 0
        } else {
            artitionId = 0
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
        if let list = try? values.decodeIfPresent([ProductImage].self, forKey: .productImages) {
           productImages.append(objectsIn: list)
        }
        if let list = try? values.decodeIfPresent(ClusterDetails.self, forKey: .cluster) {
            clusterId = list.entityID
        }
        if let list = try? values.decodeIfPresent(ProductCategory.self, forKey: .productCategory) {
            productCategoryId = list.entityID
        }
        if let list = try? values.decodeIfPresent(ProductType.self, forKey: .productType) {
            productTypeId = list.entityID
        }
        if let list = try? values.decodeIfPresent([WeaveType].self, forKey: .productWeaves) {
            weaves.append(objectsIn:list)
        }
        if let list = try? values.decodeIfPresent([ProductCareType].self, forKey: .productCares) {
            productCares.append(objectsIn:list)
        }
    }
}

class WeaveType: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityId: Int = 0
    @objc dynamic var productId: Int = 0
    @objc dynamic var weaveId: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "productId"
        case weaveId = "weaveId"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityId = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityId)"
        productId = try (values.decodeIfPresent(Int.self, forKey: .productId) ?? 0)
        weaveId = try (values.decodeIfPresent(Int.self, forKey: .weaveId) ?? 0)
    }
}

class ProductCareType: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityId: Int = 0
    @objc dynamic var productId: Int = 0
    @objc dynamic var productCareId: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "productId"
        case productCareId = "productCareId"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityId = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityId)"
        productId = try (values.decodeIfPresent(Int.self, forKey: .productId) ?? 0)
        productCareId = try (values.decodeIfPresent(Int.self, forKey: .productCareId) ?? 0)
    }
}
