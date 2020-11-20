//
//  AdminUser.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminUser: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var brandName: String?
    @objc dynamic var cluster: String?
    @objc dynamic var dateAdded: Date?
    @objc dynamic var email: String?
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var mobile: String?
    @objc dynamic var rating: Float = 0.0
    @objc dynamic var status: Int = 0
    @objc dynamic var weaverId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case brandName = "brandName"
        case cluster = "cluster"
        case dateAdded = "dateAdded"
        case email = "email"
        case firstName = "firstName"
        case lastName = "lastName"
        case mobile = "mobile"
        case rating = "rating"
        case status = "status"
        case weaverId = "weaverId"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        if let name = try? values.decodeIfPresent(String.self, forKey: .brandName) {
            brandName = name
        }else {
            brandName = ""
        }
        cluster = try? values.decodeIfPresent(String.self, forKey: .cluster) ?? ""
        if let date = try? values.decodeIfPresent(String.self, forKey: .dateAdded) {
            dateAdded = Date().ttceISODate(isoDate: date)
        }
        email = try? values.decodeIfPresent(String.self, forKey: .email) ?? ""
        if let name = try? values.decodeIfPresent(String.self, forKey: .firstName) {
            firstName = name
        }else {
            firstName = ""
        }
        if let name = try? values.decodeIfPresent(String.self, forKey: .lastName) {
            lastName = name
        }else {
            lastName = ""
        }
        mobile = try? values.decodeIfPresent(String.self, forKey: .mobile) ?? ""
        rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? 0.0
        status = try values.decodeIfPresent(Int.self, forKey: .status) ?? 0
        weaverId = try? values.decodeIfPresent(String.self, forKey: .weaverId)
    }
}
