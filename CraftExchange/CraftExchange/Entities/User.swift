//
//  User.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class User: Object, Decodable {

  @objc dynamic var entityID: Int = 0
  @objc dynamic var firstName: String?
  @objc dynamic var lastName: String?
  @objc dynamic var email: String?
  @objc dynamic var password: String?
  @objc dynamic var designation: String?
  @objc dynamic var mobile: String?
  @objc dynamic var alternateMobile: String?
  @objc dynamic var pancard: String?
  @objc dynamic var websiteLink: String?
  @objc dynamic var socialMediaLink: String?
  @objc dynamic var addressId: String?
  @objc dynamic var buyerCompanyDetailsId: String?
  @objc dynamic var weaverId: String?
  @objc dynamic var refRoleId: String?
  @objc dynamic var registeredOn: String?
  @objc dynamic var status: String?
  @objc dynamic var emailVerified: String?
  @objc dynamic var lastLoggedIn: String?

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case firstName = "first_name"
    case lastName = "last_name"
    case email = "email"
    case password = "password"
    case designation = "designation"
    case mobile = "mobile"
    case alternateMobile = "alternate_mobile"
    case pancard = "pancard"
    case websiteLink = "website_link"
    case socialMediaLink = "social_media_link"
    case addressId = "address_id"
    case buyerCompanyDetailsId = "buyer_company_details_id"
    case weaverId = "weaver_id"
    case refRoleId = "ref_role_id"
    case registeredOn = "registered_on"
    case status = "status"
    case emailVerified = "email_verified"
    case lastLoggedIn = "last_logged_in"
  }

  convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
    entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
    firstName = try? values.decodeIfPresent(String.self, forKey: .firstName)
    lastName = try? values.decodeIfPresent(String.self, forKey: .lastName)
    email = try? values.decodeIfPresent(String.self, forKey: .email)
    password = try? values.decodeIfPresent(String.self, forKey: .password)
    designation = try? values.decodeIfPresent(String.self, forKey: .designation)
    mobile = try? values.decodeIfPresent(String.self, forKey: .mobile)
    alternateMobile = try? values.decodeIfPresent(String.self, forKey: .alternateMobile)
    pancard = try? values.decodeIfPresent(String.self, forKey: .pancard)
    websiteLink = try? values.decodeIfPresent(String.self, forKey: .websiteLink)
    socialMediaLink = try? values.decodeIfPresent(String.self, forKey: .socialMediaLink)
    addressId = try? values.decodeIfPresent(String.self, forKey: .addressId)
    buyerCompanyDetailsId = try? values.decodeIfPresent(String.self, forKey: .buyerCompanyDetailsId)
    weaverId = try? values.decodeIfPresent(String.self, forKey: .weaverId)
    refRoleId = try? values.decodeIfPresent(String.self, forKey: .refRoleId)
    registeredOn = try? values.decodeIfPresent(String.self, forKey: .registeredOn)
    status = try? values.decodeIfPresent(String.self, forKey: .status)
    emailVerified = try? values.decodeIfPresent(String.self, forKey: .emailVerified)
    lastLoggedIn = try? values.decodeIfPresent(String.self, forKey: .lastLoggedIn)
  }
}
