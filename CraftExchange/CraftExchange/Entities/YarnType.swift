//
//  YarnType.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Foundation
import Realm
import RealmSwift

class YarnType: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var yarnTypeDesc: String?
    @objc dynamic var manual: Bool = false
    var yarnCounts = List<YarnCount>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case yarnTypeDesc = "yarnTypeDesc"
        case manual = "manual"
        case yarnCounts = "yarnCounts"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        yarnTypeDesc = try values.decodeIfPresent(String.self, forKey: .yarnTypeDesc)
        manual = try (values.decodeIfPresent(Bool.self, forKey: .manual) ?? false)
        if let list = try? values.decodeIfPresent([YarnCount].self, forKey: .yarnCounts) {
            yarnCounts.append(objectsIn: list)
        }
    }
}
