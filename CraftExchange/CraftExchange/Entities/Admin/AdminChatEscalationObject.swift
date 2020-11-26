//
//  AdminChatEscalationObject.swift
//  CraftExchange
//
//  Created by Kalyan on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminChatEscalationObject: Object, Decodable {
    @objc dynamic var category: String?
    @objc dynamic var date: String?
    @objc dynamic var text: String?
    @objc dynamic var isResolved: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case category = "category"
        case date = "date"
        case text = "text"
        case isResolved = "isResolved"
    }
    
    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
      category = try? values.decodeIfPresent(String.self, forKey: .category)
      date = try? values.decodeIfPresent(String.self, forKey: .date)
      text = try? values.decodeIfPresent(String.self, forKey: .text)
      isResolved = try (values.decodeIfPresent(Int.self, forKey: .isResolved) ?? 0)
    }
}
