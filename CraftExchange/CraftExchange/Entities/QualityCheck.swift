//
//  QualityCheck.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class QualityCheck: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var stageId: Int = 0
    @objc dynamic var questionId: Int = 0
    @objc dynamic var artisanId: Int = 0
    @objc dynamic var isSend: Int = 0
    @objc dynamic var answer: String?
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var createdOn: Date?
    @objc dynamic var modifiedOn: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case questionId = "questionId"
        case artisanId = "artisanId"
        case isSend = "isSend"
        case answer = "answer"
        case enquiryId = "enquiryId"
        case stageId = "stageId"
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
        questionId = try (values.decodeIfPresent(Int.self, forKey: .questionId) ?? 0)
        answer = try? values.decodeIfPresent(String.self, forKey: .answer)
        artisanId = try (values.decodeIfPresent(Int.self, forKey: .artisanId) ?? 0)
        isSend = try (values.decodeIfPresent(Int.self, forKey: .isSend) ?? 0)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        stageId = try (values.decodeIfPresent(Int.self, forKey: .stageId) ?? 0)
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .createdOn) {
            createdOn = Date().ttceISODate(isoDate: dateString)
        }
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .modifiedOn) {
            modifiedOn = Date().ttceISODate(isoDate: dateString)
        }
    }
}
