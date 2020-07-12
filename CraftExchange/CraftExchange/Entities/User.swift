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
  @objc dynamic var buyerCompanyDetails: BuyerCompanyDetails?
  @objc dynamic var weaverDetails: Weaver?
  @objc dynamic var cluster: ClusterDetails?
  @objc dynamic var refRoleId: String?
  @objc dynamic var registeredOn: String?
  dynamic var status: Int?
  dynamic var emailVerified: Int?
  @objc dynamic var lastLoggedIn: String?
  @objc dynamic var profilePic: String?
  @objc dynamic var logo: String?
  @objc dynamic var pointOfContact: CompanyPointOfContact?
  var addressList = List<Address>()
  var paymentAccountList = List<PaymentAccDetails>()
  var userProductCategories = List<UserProductCategory>()
  dynamic var rating: Int?
  @objc dynamic var userName: String?
  dynamic var enabled: Bool?
  @objc dynamic var authorities: String?
  dynamic var accountNonExpired: Bool?
  dynamic var accountNonLocked: Bool?
  dynamic var credentialsNonExpired: Bool?
  @objc dynamic var logoUrl: String?
  @objc dynamic var profilePicUrl: String?
    
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case firstName = "firstName"
    case lastName = "lastName"
    case email = "email"
    case password = "password"
    case designation = "designation"
    case mobile = "mobile"
    case alternateMobile = "alternateMobile"
    case pancard = "pancard"
    case websiteLink = "websiteLink"
    case socialMediaLink = "socialMediaLink"
    case buyerCompanyDetails = "companyDetails"
    case weaverDetails = "weaverDetails"
    case cluster = "cluster"
    case refRoleId = "refRoleId"
    case registeredOn = "registeredOn"
    case status = "status"
    case emailVerified = "emailVerified"
    case lastLoggedIn = "lastLoggedIn"
    case profilePic = "profilePic"
    case pointOfContact = "pointOfContact"
    case addressList = "addressses"
    case rating = "rating"
    case paymentAccountList = "paymentAccountDetails"
    case userName = "userName"
    case enabled = "enabled"
    case authorities = "authorities"
    case accountNonExpired = "accountNonExpired"
    case accountNonLocked = "accountNonLocked"
    case credentialsNonExpired = "credentialsNonExpired"
    case userProductCategories = "userProductCategories"
    case logo = "logo"
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
    buyerCompanyDetails = try? values.decodeIfPresent(BuyerCompanyDetails.self, forKey: .buyerCompanyDetails)
    pointOfContact = try? values.decodeIfPresent(CompanyPointOfContact.self, forKey: .pointOfContact)
    weaverDetails = try? values.decodeIfPresent(Weaver.self, forKey: .weaverDetails)
    cluster = try? values.decodeIfPresent(ClusterDetails.self, forKey: .cluster)
    refRoleId = try? values.decodeIfPresent(String.self, forKey: .refRoleId)
    registeredOn = try? values.decodeIfPresent(String.self, forKey: .registeredOn)
    status = try? values.decodeIfPresent(Int.self, forKey: .status)
    emailVerified = try? values.decodeIfPresent(Int.self, forKey: .emailVerified)
    lastLoggedIn = try? values.decodeIfPresent(String.self, forKey: .lastLoggedIn)
    profilePic = try? values.decodeIfPresent(String.self, forKey: .profilePic)
    if let list = try? values.decodeIfPresent([Address].self, forKey: .addressList) {
        addressList.append(objectsIn: list)
    }
    rating = try? values.decodeIfPresent(Int.self, forKey: .rating)
    if let list = try? values.decodeIfPresent([PaymentAccDetails].self, forKey: .paymentAccountList) {
        paymentAccountList.append(objectsIn: list)
    }
    userName = try? values.decodeIfPresent(String.self, forKey: .userName)
    enabled = try? values.decodeIfPresent(Bool.self, forKey: .enabled)
    accountNonLocked = try? values.decodeIfPresent(Bool.self, forKey: .accountNonLocked)
    accountNonExpired = try? values.decodeIfPresent(Bool.self, forKey: .accountNonExpired)
    credentialsNonExpired = try? values.decodeIfPresent(Bool.self, forKey: .credentialsNonExpired)
    if let list = try? values.decodeIfPresent([UserProductCategory].self, forKey: .userProductCategories) {
        userProductCategories.append(objectsIn: list)
    }
    logo = try? values.decodeIfPresent(String.self, forKey: .logo)
    }
    
}
