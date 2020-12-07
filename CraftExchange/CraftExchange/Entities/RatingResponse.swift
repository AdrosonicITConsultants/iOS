//
//  RatingResponse.swift
//  CraftExchange
//
//  Created by Kalyan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RatingResponseArtisan: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var questionId: Int = 0
    @objc dynamic var response: Int = 0
    @objc dynamic var responseComment: String?
    @objc dynamic var givenBy: Int = 0
    @objc dynamic var givenTo: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case questionId = "questionId"
        case response = "response"
        case responseComment = "responseComment"
        case givenBy = "givenBy"
        case givenTo = "givenTo"
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
        questionId = try (values.decodeIfPresent(Int.self, forKey: .questionId) ?? 0)
        response = try (values.decodeIfPresent(Int.self, forKey: .response) ?? 0)
        responseComment = try? values.decodeIfPresent(String.self, forKey: .responseComment)
        givenBy = try (values.decodeIfPresent(Int.self, forKey: .givenBy) ?? 0)
        givenTo = try (values.decodeIfPresent(Int.self, forKey: .givenTo) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
        
    }
}

import Foundation
import Realm
import RealmSwift

class RatingResponseBuyer: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var questionId: Int = 0
    @objc dynamic var response: Int = 0
    @objc dynamic var responseComment: String?
    @objc dynamic var givenBy: Int = 0
    @objc dynamic var givenTo: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case questionId = "questionId"
        case response = "response"
        case responseComment = "responseComment"
        case givenBy = "givenBy"
        case givenTo = "givenTo"
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
        questionId = try (values.decodeIfPresent(Int.self, forKey: .questionId) ?? 0)
        response = try (values.decodeIfPresent(Int.self, forKey: .response) ?? 0)
        responseComment = try? values.decodeIfPresent(String.self, forKey: .responseComment)
        givenBy = try (values.decodeIfPresent(Int.self, forKey: .givenBy) ?? 0)
        givenTo = try (values.decodeIfPresent(Int.self, forKey: .givenTo) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
        
    }
}

