//
//  CXUser.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

struct CXUser {

  var address: LocalAddress?
  var alternateMobile: String?
  var buyerCompanyDetails: buyerCompDetails?
  var buyerPointOfContact: pointOfContact?
  var clusterId: Int = 0
  var designation: String?
  var email: String?
  var firstName: String?
  var lastName: String?
  var mobile: String?
  var pancard: String?
  var password: String?
  var productCategoryIds : [Int]? = [0]
  var refRoleId: Int = 0
  var socialMediaLink: String?
  var weaverId: String?
  var websiteLink: String?
}

extension CXUser {
  func toJSON() -> [String: Any] {
    var message: [String: Any] = [:]
    
    message["clusterId"] = clusterId
    message["productCategoryIds"] = productCategoryIds
    message["refRoleId"] = refRoleId
    
    if refRoleId == 1 { //Artisan
      if let weaverId = weaverId {
          message["weaverId"] = weaverId
      }
    }else { // Buyer
      if let buyerCompanyDetails = buyerCompanyDetails {
        let json = buyerCompanyDetails.toJSON()
        message["buyerCompanyDetails"] = json
      }
      if let buyerPointOfContact = buyerPointOfContact {
        let json = buyerPointOfContact.toJSON()
        message["buyerPointOfContact"] = json
      }
    }
    if let address = address {
      let json = address.toJSON()
      message["address"] = json
    }
    if let alternateMobile = alternateMobile {
        message["alternateMobile"] = alternateMobile
    }
    if let designation = designation {
        message["designation"] = designation
    }
    if let email = email {
        message["email"] = email
    }
    if let firstName = firstName {
        message["firstName"] = firstName
    }
    if let lastName = lastName {
        message["lastName"] = lastName
    }
    if let mobile = mobile {
        message["mobile"] = mobile
    }
    if let pancard = pancard {
        message["pancard"] = pancard
    }
    if let password = password {
        message["password"] = password
    }
    if let socialMediaLink = socialMediaLink {
        message["socialMediaLink"] = socialMediaLink
    }
    if let websiteLink = websiteLink {
        message["websiteLink"] = websiteLink
    }
    return message
  }
}

struct LocalAddress {
  var id: Int = 0
  let addrType: (addrId: Int, addrType: String)?
  var country: (countryId: Int, countryName: String)?
  var city: String?
  var district: String?
  var landmark: String?
  var line1: String?
  var line2: String?
  var pincode: String?
  var state: String?
  var street: String?
  var userId: Int = 0
}

extension LocalAddress {
  func toJSON() -> [String: Any] {
    var message: [String: Any] = [:]
    
    message["id"] = id
    message["userId"] = id
    
    if let addrType = addrType {
      var json: [String: Any] = [:]
      json["id"] = addrType.addrId
      json["addrType"] = addrType.addrType
      message["addressType"] = json
    }
    if let country = country {
      var json: [String: Any] = [:]
      json["id"] = country.countryId
      json["name"] = country.countryName
      message["country"] = json
    }
    if let city = city {
        message["city"] = city
    }
    if let district = district {
        message["district"] = district
    }
    if let landmark = landmark {
        message["landmark"] = landmark
    }
    if let line1 = line1 {
        message["line1"] = line1
    }
    if let line2 = line2 {
        message["line2"] = line2
    }
    if let pincode = pincode {
        message["pincode"] = pincode
    }
    if let state = state {
        message["state"] = state
    }
    if let street = street {
        message["street"] = street
    }
    return message
  }
}

struct pointOfContact {
  var id: Int = 0
  let contactNo: String?
  var email: String?
  var firstName: String?
  var lastName: String?
}

extension pointOfContact {
  func toJSON() -> [String: Any] {
    var message: [String: Any] = [:]
    
    message["id"] = id
    if let contactNo = contactNo {
        message["contactNo"] = contactNo
    }
    if let email = email {
        message["email"] = email
    }
    if let firstName = firstName {
        message["firstName"] = firstName
    }
    if let lastName = lastName {
        message["lastName"] = lastName
    }
    
    return message
  }
}

struct buyerCompDetails {
  var id: Int = 0
  let companyName: String?
  var cin: String?
  var contact: String?
  var gstNo: String?
  var logo: String?
}

extension buyerCompDetails {
  func toJSON() -> [String: Any] {
    var message: [String: Any] = [:]
    
    message["id"] = id
    if let companyName = companyName {
        message["companyName"] = companyName
    }
    if let cin = cin {
        message["cin"] = cin
    }
    if let contact = contact {
        message["contact"] = contact
    }
    if let gstNo = gstNo {
        message["gstNo"] = gstNo
    }
    if let logo = logo {
        message["logo"] = logo
    }
    
    return message
  }
}
