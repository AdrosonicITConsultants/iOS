//
//  Conversation.swift
//  CraftExchange
//
//  Created by Kalyan on 14/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Conversation: Object, Decodable {
    
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var isBuyer: Int = 0
    @objc dynamic var messageFrom: Int = 0
    @objc dynamic var messageTo: Int = 0
    @objc dynamic var messageString: String?
    @objc dynamic var mediaType: Int = 0
    @objc dynamic var mediaName: String?
    @objc dynamic var path: String?
    @objc dynamic var seen: Int = 0
    @objc dynamic var isDelete: Int = 0
    @objc dynamic var createdOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case messageFrom = "messageFrom"
        case messageTo = "messageTo"
        case messageString = "messageString"
        case mediaType = "mediaType"
        case mediaName = "mediaName"
        case path = "path"
        case seen = "seen"
        case isDelete = "isDelete"
        case createdOn = "createdOn"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        messageFrom = try (values.decodeIfPresent(Int.self, forKey: .messageFrom) ?? 0)
        messageTo = try (values.decodeIfPresent(Int.self, forKey: .messageTo) ?? 0)
        messageString = try? values.decodeIfPresent(String.self, forKey: .messageString)
        mediaType = try (values.decodeIfPresent(Int.self, forKey: .mediaType) ?? 0)
        mediaName = try? values.decodeIfPresent(String.self, forKey: .mediaName)
        path = try? values.decodeIfPresent(String.self, forKey: .path)
        seen = try (values.decodeIfPresent(Int.self, forKey: .seen) ?? 0)
        isDelete = try (values.decodeIfPresent(Int.self, forKey: .isDelete) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        
    }
}

