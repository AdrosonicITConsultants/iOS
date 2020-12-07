//
//  ChangeRequestItem.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ChangeRequestItem: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var requestText: String?
    @objc dynamic var changeRequestId: Int = 0
    @objc dynamic var requestItemsId: Int = 0
    @objc dynamic var requestStatus: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case requestText = "requestText"
        case changeRequestId = "changeRequestId"
        case requestItemsId = "requestItemsId"
        case requestStatus = "requestStatus"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        requestText = try? values.decodeIfPresent(String.self, forKey: .requestText)
        changeRequestId = try (values.decodeIfPresent(Int.self, forKey: .changeRequestId) ?? 0)
        requestItemsId = try (values.decodeIfPresent(Int.self, forKey: .requestItemsId) ?? 0)
        requestStatus = try (values.decodeIfPresent(Int.self, forKey: .requestStatus) ?? 0)
    }
}
