//
//  AdminTeammate.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 18/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminTeammate: Object, Decodable {

    @objc dynamic var id: Int = 0
    @objc dynamic var username: String?
    @objc dynamic var role: String?
    @objc dynamic var email: String?
    

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case role = "role"
        case email = "email"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        username = try? values.decodeIfPresent(String.self, forKey: .username)
        role = try? values.decodeIfPresent(String.self, forKey: .role)
        email = try? values.decodeIfPresent(String.self, forKey: .email)
    }
}
