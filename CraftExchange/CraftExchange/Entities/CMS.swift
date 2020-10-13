//
//  CMS.swift
//  CraftExchange
//
//  Created by Kalyan on 09/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CMSCategoryACF: Object, Decodable {
    
 @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
 @objc dynamic var image: String?
    @objc dynamic var catDescription: String?
    
    enum CodingKeys: String, CodingKey  {
        case id = "category_id"
        case image = "image"
        case catDescription = "description"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
       let entity = try? values.decodeIfPresent(String.self, forKey: .id) ?? "0"
        entityID = Int(entity!)!
        id = entity!
        image = try? values.decodeIfPresent(String.self, forKey: .image)
        catDescription = try? values.decodeIfPresent(String.self, forKey: .catDescription)
    }
}

class CMSRegionACF: Object, Decodable {
    
 @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
 @objc dynamic var image: String?
    @objc dynamic var regDescription: String?
    
    enum CodingKeys: String, CodingKey  {
        case id = "cluster_id"
        case image = "image"
         case regDescription = "description"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
       let entity = try? values.decodeIfPresent(String.self, forKey: .id) ?? "0"
        entityID = Int(entity!)!
        id = entity!
        image = try? values.decodeIfPresent(String.self, forKey: .image)
        regDescription = try? values.decodeIfPresent(String.self, forKey: .regDescription)
    }
}
