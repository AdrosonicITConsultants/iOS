//
//  EscalationCategory.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class EscalationCategory: Object, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var category: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case category = "category"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        category = try? values.decodeIfPresent(String.self, forKey: .category)
    }
}


