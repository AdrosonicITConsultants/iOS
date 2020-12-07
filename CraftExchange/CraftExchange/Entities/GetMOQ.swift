//
//  GetMOQ.swift
//  CraftExchange
//
//  Created by Kalyan on 21/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class GetMOQ: Object, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var moq: Int = 0
    @objc dynamic var ppu: String?
    @objc dynamic var deliveryTimeId: Int = 0
    @objc dynamic var isSend: Int = 0
    @objc dynamic var additionalInfo: String?
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case moq = "moq"
        case ppu = "ppu"
        case deliveryTimeId = "deliveryTimeId"
        case isSend = "isSend"
        case entityID = "entityID"
        case additionalInfo = "additionalInfo"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
        
    }
    
    //    override class func primaryKey() -> String? {
    //        return "id"
    //
    //
    //    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        moq = try (values.decodeIfPresent(Int.self, forKey: .moq) ?? 0)
        ppu = try values.decodeIfPresent(String.self, forKey: .ppu)
        deliveryTimeId = try (values.decodeIfPresent(Int.self, forKey: .deliveryTimeId) ?? 0)
        isSend = try (values.decodeIfPresent(Int.self, forKey: .isSend) ?? 0)
        additionalInfo = try values.decodeIfPresent(String.self, forKey: .additionalInfo)
        createdOn = try values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try values.decodeIfPresent(String.self, forKey: .modifiedOn)
        
    }
}


