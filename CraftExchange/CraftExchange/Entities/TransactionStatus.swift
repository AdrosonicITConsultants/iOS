//
//  TransactionStatus.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TransactionStatus: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var transactionId: Int = 0
    @objc dynamic var type: String?
    @objc dynamic var viewType: String?
    @objc dynamic var buyerText: String?
    @objc dynamic var artisanText: String?
    @objc dynamic var transactionStage: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case transactionId = "transactionId"
        case type = "type"
        case viewType = "viewType"
        case buyerText = "buyerText"
        case artisanText = "artisanText"
        case transactionStage = "transactionStage"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        transactionId = try (values.decodeIfPresent(Int.self, forKey: .transactionId) ?? 0)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        viewType = try values.decodeIfPresent(String.self, forKey: .viewType)
        buyerText = try values.decodeIfPresent(String.self, forKey: .buyerText)
        artisanText = try values.decodeIfPresent(String.self, forKey: .artisanText)
        transactionStage = try values.decodeIfPresent(String.self, forKey: .transactionStage)
    }
}
