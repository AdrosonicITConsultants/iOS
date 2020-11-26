//
//  AdminEscalation.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminEscalation: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var date: Date?
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var enquiryCode: String?
    @objc dynamic var artistBrand: String?
    @objc dynamic var buyerBrand: String?
    @objc dynamic var cluster: String?
    @objc dynamic var stage: String?
    @objc dynamic var lastUpdated: Date?
    @objc dynamic var concern: String?
    @objc dynamic var price: Float = 0.0
    @objc dynamic var category: String?
    @objc dynamic var raisedBy: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "escalationId"
        case date = "date"
        case enquiryId = "enquiryId"
        case enquiryCode = "enquiryCode"
        case artistBrand = "artistBrand"
        case buyerBrand = "buyerBrand"
        case cluster = "cluster"
        case stage = "stage"
        case lastUpdated = "lastUpdated"
        case concern = "concern"
        case price = "price"
        case category = "category"
        case raisedBy = "raisedBy"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        if let newdate = try? values.decodeIfPresent(String.self, forKey: .date) {
            date = Date().ttceISODate(isoDate: newdate)
        }
        enquiryId = try values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0
        enquiryCode = try? values.decodeIfPresent(String.self, forKey: .enquiryCode)
        artistBrand = try? values.decodeIfPresent(String.self, forKey: .artistBrand)
        buyerBrand = try? values.decodeIfPresent(String.self, forKey: .buyerBrand)
        cluster = try? values.decodeIfPresent(String.self, forKey: .cluster)
        stage = try? values.decodeIfPresent(String.self, forKey: .stage)
        if let newdate = try? values.decodeIfPresent(String.self, forKey: .lastUpdated) {
            lastUpdated = Date().ttceISODate(isoDate: newdate)
        }
        concern = try? values.decodeIfPresent(String.self, forKey: .concern)
        price = try values.decodeIfPresent(Float.self, forKey: .price) ?? 0.0
        category = try? values.decodeIfPresent(String.self, forKey: .category)
        raisedBy = try values.decodeIfPresent(Int.self, forKey: .raisedBy) ?? 0
    }
}
