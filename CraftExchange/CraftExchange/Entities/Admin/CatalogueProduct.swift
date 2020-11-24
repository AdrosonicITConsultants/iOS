//
//  CatalogueProduct.swift
//  CraftExchange
//
//  Created by Kalyan on 20/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CatalogueProduct: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var userID: Int = 0
    @objc dynamic var clusterName: String?
    @objc dynamic var isDeleted: Int = 0
    @objc dynamic var images: String?
    @objc dynamic var code: String?
    @objc dynamic var name: String?
    @objc dynamic var productId: Int = 0
    @objc dynamic var icon:  Int = 0
    @objc dynamic var availability: String?
    @objc dynamic var category: String?
    @objc dynamic var dateAdded: String?
    @objc dynamic var brand: String?
    @objc dynamic var orderGenerated: Int = 0
    @objc dynamic var count:  Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case images = "images"
        case code = "code"
        case name = "name"
        case clusterName = "clusterName"
        case productId = "productId"
        case icon = "icon"
        case availability = "availability"
        case category = "category"
        case dateAdded = "dateAdded"
        case brand = "brand"
        case orderGenerated = "orderGenerated"
        case count = "count"
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        clusterName = try? values.decodeIfPresent(String.self, forKey: .clusterName)
        images = try? values.decodeIfPresent(String.self, forKey: .images)
        code = try? values.decodeIfPresent(String.self, forKey: .code)
         name = try? values.decodeIfPresent(String.self, forKey: .name)
        productId = try (values.decodeIfPresent(Int.self, forKey: .productId) ?? 0)
        icon = try (values.decodeIfPresent(Int.self, forKey: .icon) ?? 0)
        availability = try? values.decodeIfPresent(String.self, forKey: .availability)
        category = try? values.decodeIfPresent(String.self, forKey: .category)
        dateAdded = try? values.decodeIfPresent(String.self, forKey: .dateAdded)
        brand = try? values.decodeIfPresent(String.self, forKey: .brand)
        orderGenerated = try (values.decodeIfPresent(Int.self, forKey: .orderGenerated) ?? 0)
        count = try (values.decodeIfPresent(Int.self, forKey: .count) ?? 0)
        
        
    }
}

