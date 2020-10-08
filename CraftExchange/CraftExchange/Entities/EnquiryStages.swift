//
//  EnquiryStages.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class EnquiryStages: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var stageDescription: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case stageDescription = "desc"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        stageDescription = try values.decodeIfPresent(String.self, forKey: .stageDescription)
    }
}

class EnquiryInnerStages: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var stageDescription: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case stageDescription = "stage"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        stageDescription = try values.decodeIfPresent(String.self, forKey: .stageDescription)
    }
}
