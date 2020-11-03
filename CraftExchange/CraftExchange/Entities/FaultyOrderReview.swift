//
//  FaultyOrderReview.swift
//  CraftExchange
//
//  Created by Kalyan on 03/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ArtisanFaultyOrder: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var comment: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case comment = "comment"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
    }
}

class BuyerFaultyOrder: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var comment: String?
    @objc dynamic var subComment: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case comment = "comment"
        case subComment = "subComment"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
         subComment = try values.decodeIfPresent(String.self, forKey: .subComment)
    }
}
