//
//  Yarn.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Yarn: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var yarnDesc: String?
    var yarnType = List<YarnType>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case yarnDesc = "yarnDesc"
        case yarnType = "yarnType"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        yarnDesc = try values.decodeIfPresent(String.self, forKey: .yarnDesc)
        if let list = try? values.decodeIfPresent(YarnType.self, forKey: .yarnType) {
            yarnType.append(list)
        }
    }
}
