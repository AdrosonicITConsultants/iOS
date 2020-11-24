//
//  SelectArtisanBrand.swift
//  CraftExchange
//
//  Created by Kalyan on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class SelectArtisanBrand: Object, Decodable {
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var cluster: String?
    @objc dynamic var brand: String?
    @objc dynamic var rating: Double = 0.0
    @objc dynamic var weaverId: String?
    @objc dynamic var status: Int = 0
    @objc dynamic var email: String?
    @objc dynamic var contact: String?
    @objc dynamic var state: String?
    
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case cluster = "cluster"
        case brand = "brand"
        case rating = "rating"
        case weaverId = "weaverId"
        case status = "status"
        case email = "email"
        case contact = "contact"
        case state = "state"
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        cluster = try? values.decodeIfPresent(String.self, forKey: .cluster)
        brand = try? values.decodeIfPresent(String.self, forKey: .brand)
        rating = try (values.decodeIfPresent(Double.self, forKey: .rating) ?? 0)
         weaverId = try? values.decodeIfPresent(String.self, forKey: .weaverId)
        status = try (values.decodeIfPresent(Int.self, forKey: .status) ?? 0)
        email = try? values.decodeIfPresent(String.self, forKey: .email)
        contact = try? values.decodeIfPresent(String.self, forKey: .contact)
        state = try? values.decodeIfPresent(String.self, forKey: .state)
        
        
        
    }
}


