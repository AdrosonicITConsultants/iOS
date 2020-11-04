//
//  QCQuestions.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class QCQuestions: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var stageId: Int = 0
    @objc dynamic var questionNo: Int = 0
    @objc dynamic var question: String?
    @objc dynamic var answerType: String?
    @objc dynamic var optionValue: String?
    @objc dynamic var isDelete: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case stageId = "stageId"
        case questionNo = "questionNo"
        case question = "question"
        case answerType = "answerType"
        case optionValue = "optionValue"
        case isDelete = "isDelete"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        questionNo = try (values.decodeIfPresent(Int.self, forKey: .questionNo) ?? 0)
        stageId = try (values.decodeIfPresent(Int.self, forKey: .stageId) ?? 0)
        question = try? values.decodeIfPresent(String.self, forKey: .question)
        answerType = try? values.decodeIfPresent(String.self, forKey: .answerType)
        optionValue = try? values.decodeIfPresent(String.self, forKey: .optionValue)
        isDelete = try (values.decodeIfPresent(Int.self, forKey: .isDelete) ?? 0)
    }
}
