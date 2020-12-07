//
//  ChangeRequest.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ChangeRequest: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var createdOn: Date?
    @objc dynamic var modifiedOn: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case status = "status"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
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
        status = try (values.decodeIfPresent(Int.self, forKey: .status) ?? 0)
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .createdOn) {
            createdOn = Date().ttceISODate(isoDate: dateString)
        }
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .modifiedOn) {
            modifiedOn = Date().ttceISODate(isoDate: dateString)
        }
    }
}

