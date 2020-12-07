//
//  GetMOQs.swift
//  CraftExchange
//
//  Created by Kalyan on 21/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Foundation
import Realm
import RealmSwift

class GetMOQs: Object, Decodable {
    var moq: GetMOQ?
    @objc dynamic var artisanId: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var brand: String?
    @objc dynamic var logo:  String?
    @objc dynamic var clusterName: String?
    @objc dynamic var state: String?
    var accepted: Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case moq = "moq"
        case artisanId = "artisanId"
        case enquiryId = "enquiryId"
        case brand = "brand"
        case logo = "logo"
        case clusterName = "clusterName"
        case state = "state"
        case accepted = "accepted"
        
    }
    
    //    override class func primaryKey() -> String? {
    //        return "id"
    //
    //
    //    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        artisanId = try (values.decodeIfPresent(Int.self, forKey: .artisanId) ?? 0)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        
        moq = try? values.decodeIfPresent(GetMOQ.self, forKey: .moq)
        brand = try values.decodeIfPresent(String.self, forKey: .brand)
        logo = try values.decodeIfPresent(String.self, forKey: .logo)
        clusterName = try values.decodeIfPresent(String.self, forKey: .clusterName)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        accepted = try values.decodeIfPresent(Bool.self, forKey: .accepted)
        
    }
}

