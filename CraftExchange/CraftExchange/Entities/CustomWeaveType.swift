//
//  CustomWeaveType.swift
//  CraftExchange
//
//  Created by Preety Singh on 20/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CustomWeaveType: Object, Decodable {
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
