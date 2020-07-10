//
//  Weaver.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Weaver: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var weaverId: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case weaverId = "weaverId"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
      weaverId = try? values.decodeIfPresent(String.self, forKey: .weaverId)
    }
}

