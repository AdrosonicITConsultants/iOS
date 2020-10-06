//
//  PaymentArtist.swift
//  CraftExchange
//
//  Created by Kiran Songire on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import Realm
import RealmSwift

class PaymentArtist: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var label: String?
    @objc dynamic var paymentId: Int = 0
    @objc dynamic var isLatest:  Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case label = "label"
        case paymentId = "paymentId"
        case isLatest = "isLatest"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
        
    }
    
    
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        label = try? values.decodeIfPresent(String.self, forKey: .label)
        paymentId = try (values.decodeIfPresent(Int.self, forKey: .paymentId) ?? 0)
        isLatest = try (values.decodeIfPresent(Int.self, forKey: .isLatest) ?? 0)
        createdOn = try? values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try? values.decodeIfPresent(String.self, forKey: .modifiedOn)
        
        
    }
}
