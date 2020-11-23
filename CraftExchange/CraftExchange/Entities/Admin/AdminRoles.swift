//
//  AdminRoles.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 18/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminRoles: Object, Decodable {

    @objc dynamic var id: Int = 0
    @objc dynamic var desc: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case desc = "desc"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        desc = try? values.decodeIfPresent(String.self, forKey: .desc)
    }
}
