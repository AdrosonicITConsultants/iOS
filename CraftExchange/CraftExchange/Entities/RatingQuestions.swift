//
//  RatingQuestions.swift
//  CraftExchange
//
//  Created by Kalyan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RatingQuestionsArtisan: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var question: String?
    @objc dynamic var questionNo: Int = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var isDelete: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    @objc dynamic var answerType: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case question = "question"
        case questionNo = "questionNo"
        case type = "type"
        case isDelete = "isDelete"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
        case answerType = "answerType"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
         question = try? values.decodeIfPresent(String.self, forKey: .question)
        questionNo = try (values.decodeIfPresent(Int.self, forKey: .questionNo) ?? 0)
        type = try (values.decodeIfPresent(Int.self, forKey: .type) ?? 0)
        isDelete = try (values.decodeIfPresent(Int.self, forKey: .isDelete) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
        answerType = try (values.decodeIfPresent(Int.self, forKey: .answerType) ?? 0)
    }
}

class RatingQuestionsBuyer: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var question: String?
    @objc dynamic var questionNo: Int = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var isDelete: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    @objc dynamic var answerType: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case question = "question"
        case questionNo = "questionNo"
        case type = "type"
        case isDelete = "isDelete"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
        case answerType = "answerType"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
         question = try? values.decodeIfPresent(String.self, forKey: .question)
        questionNo = try (values.decodeIfPresent(Int.self, forKey: .questionNo) ?? 0)
        type = try (values.decodeIfPresent(Int.self, forKey: .type) ?? 0)
        isDelete = try (values.decodeIfPresent(Int.self, forKey: .isDelete) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
        answerType = try (values.decodeIfPresent(Int.self, forKey: .answerType) ?? 0)
    }
}

