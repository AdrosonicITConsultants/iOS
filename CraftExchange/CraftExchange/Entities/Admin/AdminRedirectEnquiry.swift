//
//  AdminRedirectEnquiry.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminRedirectEnquiry: Object, Decodable {
    
    @objc dynamic var id: String?
    @objc dynamic var entityID: Int = 0
    @objc dynamic var typeId: Int = 0
    @objc dynamic var code: String?
    @objc dynamic var productCategory: String?
    @objc dynamic var weave: String?
    @objc dynamic var companyName: String?
    @objc dynamic var date: String?
    @objc dynamic var productId: Int = 0
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case code = "code"
        case productCategory = "productCategory"
        case weave = "weave"
        case companyName = "companyName"
        case date = "date"
        case productId = "productId"
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        code = try? values.decodeIfPresent(String.self, forKey: .code)
        productCategory = try? values.decodeIfPresent(String.self, forKey: .productCategory)
         weave = try? values.decodeIfPresent(String.self, forKey: .weave)
        companyName = try? values.decodeIfPresent(String.self, forKey: .companyName)
        date = try? values.decodeIfPresent(String.self, forKey: .date)
        productId = try (values.decodeIfPresent(Int.self, forKey: .productId) ?? 0)
        
    }
}

