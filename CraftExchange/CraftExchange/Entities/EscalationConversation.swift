//
//  EscalationConversation.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class EscalationConversation: Object, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var escalationFrom: Int = 0
    @objc dynamic var escalationTo: Int = 0
    @objc dynamic var text: String?
    @objc dynamic var category: Int = 0
    @objc dynamic var resolved: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case escalationFrom = "escalationFrom"
        case escalationTo = "escalationTo"
        case text = "text"
        case category = "category"
        case resolved = "isResolve"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        escalationFrom = try (values.decodeIfPresent(Int.self, forKey: .escalationFrom) ?? 0)
        escalationTo = try (values.decodeIfPresent(Int.self, forKey: .escalationTo) ?? 0)
        text = try? values.decodeIfPresent(String.self, forKey: .text)
        category = try (values.decodeIfPresent(Int.self, forKey: .category) ?? 0)
        resolved = try (values.decodeIfPresent(Int.self, forKey: .resolved) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
    }
}

