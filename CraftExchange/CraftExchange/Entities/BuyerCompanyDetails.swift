//
//  BuyerCompanyDetails.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class BuyerCompanyDetails: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var companyName: String?
    @objc dynamic var contact: String?
    @objc dynamic var logo: String?
    @objc dynamic var cin: String?
    @objc dynamic var gstNo: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case companyName = "company_name"
        case contact = "contact"
        case logo = "logo"
        case cin = "cin"
        case gstNo = "gst_no"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
      companyName = try? values.decodeIfPresent(String.self, forKey: .companyName)
      contact = try? values.decodeIfPresent(String.self, forKey: .contact)
      logo = try? values.decodeIfPresent(String.self, forKey: .logo)
      cin = try? values.decodeIfPresent(String.self, forKey: .cin)
      gstNo = try? values.decodeIfPresent(String.self, forKey: .gstNo)
    }
}
