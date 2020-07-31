//
//  YarnCount.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class YarnCount: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var count: String?
    @objc dynamic var yarnTypeId: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case count = "yarnTypeDesc"
        case yarnTypeId = "yarnTypeId"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        count = try values.decodeIfPresent(String.self, forKey: .count)
        yarnTypeId = try (values.decodeIfPresent(Int.self, forKey: .yarnTypeId) ?? 0)
    }
}

