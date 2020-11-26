//
//  AdminRedirectArtisan.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminRedirectArtisan: Object, Decodable {
    
    @objc dynamic var artisan: SelectArtisanBrand?
    @objc dynamic var isMailSent: Int = 0
    
    enum CodingKeys: String, CodingKey {
        
        case artisan = "artisan"
        case isMailSent = "isMailSent"
        
    }
    
    //    override class func primaryKey() -> String? {
    //        return "id"
    //    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        isMailSent = try (values.decodeIfPresent(Int.self, forKey: .isMailSent) ?? 0)
        if let obj = try? values.decodeIfPresent(SelectArtisanBrand.self, forKey: .artisan) {
            artisan = obj
        }
        
    }
}


