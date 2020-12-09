//
//  CompanyPointOfContact.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CompanyPointOfContact: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var pocFirstName: String?
    @objc dynamic var pocLastName: String?
    @objc dynamic var pocEmail: String?
    @objc dynamic var pocContantNo: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case pocFirstName = "firstName"
        case pocLastName = "lastName"
        case pocEmail = "email"
        case pocContantNo = "contactNo"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        pocFirstName = try? values.decodeIfPresent(String.self, forKey: .pocFirstName)
        pocLastName = try? values.decodeIfPresent(String.self, forKey: .pocLastName)
        pocEmail = try? values.decodeIfPresent(String.self, forKey: .pocEmail)
        pocContantNo = try? values.decodeIfPresent(String.self, forKey: .pocContantNo)
    }
}

