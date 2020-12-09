//
//  CustomProductImage.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CustomProductImage: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var lable: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case lable = "lable"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        lable = try? values.decodeIfPresent(String.self, forKey: .lable)
    }
}

