//
//  AdminNotifications.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminNotifications: Object, Decodable {
    @objc dynamic var code: String?
    @objc dynamic var createdOn: String?
    @objc dynamic var productDesc: String?
    @objc dynamic var notificationId: Int = 0
    @objc dynamic var notificationType: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case createdOn = "createdOn"
        case productDesc = "productDesc"
        case notificationType = "notificationType"
        case notificationId = "notificationId"
       
    }
    
    override class func primaryKey() -> String? {
        return "notificationId"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
      code = try? values.decodeIfPresent(String.self, forKey: .code)
      createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
      productDesc = try? values.decodeIfPresent(String.self, forKey: .productDesc)
      notificationId = try (values.decodeIfPresent(Int.self, forKey: .notificationId) ?? 0)
      notificationType = try? values.decodeIfPresent(String.self, forKey: .notificationType)
    }
}
