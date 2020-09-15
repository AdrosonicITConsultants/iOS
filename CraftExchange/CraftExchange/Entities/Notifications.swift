//
//  Notifications.swift
//  CraftExchange
//
//  Created by Kalyan on 02/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Notifications: Object, Decodable {
    @objc dynamic var code: String?
    @objc dynamic var companyName: String?
    @objc dynamic var createdOn: String?
    @objc dynamic var productDesc: String?
    @objc dynamic var notificationTypeId: Int = 0
    @objc dynamic var seen: Int = 0
    @objc dynamic var notificationId: Int = 0
    @objc dynamic var customProduct: String?
    @objc dynamic var type: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case companyName = "companyName"
        case createdOn = "createdOn"
        case productDesc = "productDesc"
        case notificationTypeId = "notificationTypeId"
        case seen = "seen"
        case notificationId = "notificationId"
        case customProduct = "customProduct"
        case type = "type"
       
    }
//    override class func primaryKey() -> String? {
//        return "notificationId"
//    }


    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
        code = try? values.decodeIfPresent(String.self, forKey: .code)
      companyName = try? values.decodeIfPresent(String.self, forKey: .companyName)
      createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
      notificationTypeId = try (values.decodeIfPresent(Int.self, forKey: .notificationTypeId) ?? 0)
      seen = try (values.decodeIfPresent(Int.self, forKey: .seen) ?? 0)
      productDesc = try? values.decodeIfPresent(String.self, forKey: .productDesc)
      
      notificationId = try (values.decodeIfPresent(Int.self, forKey: .notificationId) ?? 0)
      customProduct = try? values.decodeIfPresent(String.self, forKey: .customProduct)
      type = try? values.decodeIfPresent(String.self, forKey: .type)
    }
}
