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
  var productCategoryIds : [Int]? = []
  var refRoleId: Int = 0
  var socialMediaLink: String?
  var weaverId: String?
  var websiteLink: String?
    var profileImg: Data?
}

extension CXUser {
    func toJSON(updateAddress: Bool, buyerComp: Bool) -> [String: Any] {
    var message: [String: Any] = [:]
    
    if clusterId != 0 {
        message["clusterId"] = clusterId
    }
    if productCategoryIds != [0] {
        message["productCategoryIds"] = productCategoryIds
    }
    
    if refRoleId != 0 {
        message["refRoleId"] = refRoleId
    }
    
    if refRoleId == 1 { //Artisan
      if let weaverId = weaverId {
          message["weaverId"] = weaverId
      }
    }else { // Buyer
      if let buyerCompanyDetails = buyerCompanyDetails {
        let json = buyerCompanyDetails.toJSON()
        if buyerComp {
            message["buyerCompanyDetails"] = json
        }else {
            message["companyDetails"] = json
        }
      }
      if let buyerPointOfContact = buyerPointOfContact {
        let json = buyerPointOfContact.toJSON()
        message["buyerPointOfContact"] = json
      }
    }
    if let address = address {
        if updateAddress {
            let json = address.toUpdateAddressJSON()
            message["address"] = json
        }else {
            let json = address.toJSON()
            message["address"] = json
        }
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
    
    func toUpdateAddressJSON() -> [String: Any] {
      var message: [String: Any] = [:]

      if let country = country {
        var json: [String: Any] = [:]
        json["id"] = country.countryId
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
    var companyLogo: Data?
    var compDesc: String?
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
    if let compDesc = compDesc {
        message["desc"] = compDesc
    }
    return message
  }
}

struct bankDetails {
    var id: Int = 0
    let accNo: String?
    let accType: (accId: Int, accDesc: String)?
    var bankName: String?
    var branchName: String?
    var ifsc: String?
    var name: String?
}

extension bankDetails {
  func toJSON() -> [String: Any] {
    var message: [String: Any] = [:]
    
    if let accNo = accNo {
        message["accNo_UPI_Mobile"] = accNo
    }
    if let bankName = bankName {
        message["bankName"] = bankName
    }
    if let branchName = branchName {
        message["branch"] = branchName
    }
    if let ifsc = ifsc {
        message["ifsc"] = ifsc
    }
    if let name = name {
        message["name"] = name
    }
    if let accType = accType {
      var json: [String: Any] = [:]
      json["id"] = accType.accId
      json["accountDesc"] = accType.accDesc
      message["accountType"] = json
    }
    if let userId = User.loggedIn()?.entityID {
        message["userId"] = userId
    }
    return message
  }
}

struct productDetails {
    var id: Int = 0
    var tag: String?
    var code: String?
    var productCategoryId: Int?
    var productTypeId: Int?
    var productSpec: String?
    var weight: String?
    var statusId: Int?
    var gsm: String?
    var warpDyeId: Int?
    var warpYarnCount: String?
    var warpYarnId: Int?
    var weftDyeId: Int?
    var weftYarnCount: String?
    var weftYarnId: Int?
    var extraWeftDyeId: Int?
    var extraWeftYarnCount: String?
    var extraWeftYarnId: Int?
    var width: String?
    var length: String?
    var reedCountId: String?
    var careIds: [Int]?
    var weaveIds: [Int]?
    var relatedProduct: [relatedProductInfo]?
}

extension productDetails {
    func toJSON() -> [String: Any] {
        var product: [String: Any] = [:]

        if let tag = tag {
            product["tag"] = tag
        }
        if let code = code {
            product["code"] = code
        }
        if let productCategoryId = productCategoryId {
            product["productCategoryId"] = productCategoryId
        }
        if let productTypeId = productTypeId {
            product["productTypeId"] = productTypeId
        }
        if let productSpec = productSpec {
            product["productSpec"] = productSpec
        }
        if let weight = weight {
            product["weight"] = weight
        }
        if let statusId = statusId {
            product["statusId"] = statusId
        }
        if let gsm = gsm {
            product["gsm"] = gsm
        }
        if let warpDyeId = warpDyeId {
            product["warpDyeId"] = warpDyeId
        }
        if let warpYarnCount = warpYarnCount {
            product["warpYarnCount"] = warpYarnCount
        }
        if let warpYarnId = warpYarnId {
            product["warpYarnId"] = warpYarnId
        }
        if let weftDyeId = weftDyeId {
            product["weftDyeId"] = weftDyeId
        }
        if let weftYarnCount = weftYarnCount {
            product["weftYarnCount"] = weftYarnCount
        }
        if let weftYarnId = weftYarnId {
            product["weftYarnId"] = weftYarnId
        }
        if let extraWeftDyeId = extraWeftDyeId {
            product["extraWeftDyeId"] = extraWeftDyeId
        }
        if let extraWeftYarnCount = extraWeftYarnCount {
            product["extraWeftYarnCount"] = extraWeftYarnCount
        }
        if let extraWeftYarnId = extraWeftYarnId {
            product["extraWeftYarnId"] = extraWeftYarnId
        }
        if let width = width {
            product["width"] = width
        }
        if let length = length {
            product["length"] = length
        }
        if let reedCountId = reedCountId {
            product["reedCountId"] = reedCountId
        }
        if let careIds = careIds {
            product["careIds"] = careIds
        }
        if let weaveIds = weaveIds {
            product["weaveIds"] = weaveIds
        }
        if let relatedProduct = relatedProduct {
            var arr: [[String:Any]] = []
            relatedProduct .forEach({ (info) in
                arr.append(info.toJSON())
            })
            product["relatedProduct"] = arr
        }
        return product
    }
    func editJSON() -> [String: Any] {
        var product: [String: Any] = [:]
        
        if id != 0 {
            product["id"] = id
        }
        if let tag = tag {
            product["tag"] = tag
        }
        if let code = code {
            product["code"] = code
        }
        if let productCategoryId = productCategoryId {
            product["productCategoryId"] = productCategoryId
        }
        if let productTypeId = productTypeId {
            product["productTypeId"] = productTypeId
        }
        if let productSpec = productSpec {
            product["productSpec"] = productSpec
        }
        if let weight = weight {
            product["weight"] = weight
        }
        if let statusId = statusId {
            product["productStatusId"] = statusId
        }
        if let gsm = gsm {
            product["gsm"] = gsm
        }
        if let warpDyeId = warpDyeId {
            product["warpDyeId"] = warpDyeId
        }
        if let warpYarnCount = warpYarnCount {
            product["warpYarnCount"] = warpYarnCount
        }
        if let warpYarnId = warpYarnId {
            product["warpYarnId"] = warpYarnId
        }
        if let weftDyeId = weftDyeId {
            product["weftDyeId"] = weftDyeId
        }
        if let weftYarnCount = weftYarnCount {
            product["weftYarnCount"] = weftYarnCount
        }
        if let weftYarnId = weftYarnId {
            product["weftYarnId"] = weftYarnId
        }
        if let extraWeftDyeId = extraWeftDyeId {
            product["extraWeftDyeId"] = extraWeftDyeId
        }
        if let extraWeftYarnCount = extraWeftYarnCount {
            product["extraWeftYarnCount"] = extraWeftYarnCount
        }
        if let extraWeftYarnId = extraWeftYarnId {
            product["extraWeftYarnId"] = extraWeftYarnId
        }
        if let width = width {
            product["width"] = width
        }
        if let length = length {
            product["length"] = length
        }
        if let reedCountId = reedCountId {
            product["reedCountId"] = reedCountId
        }
        if let careIds = careIds {
            var careArray: [[String:Any]] = []
            careIds .forEach { (careId) in
                var json: [String: Any] = [:]
                json["id"] = 0
                json["productCareId"] = careId
                json["productId"] = id
                careArray.append(json)
            }
            product["productCares"] = careArray
        }
        if let weaveIds = weaveIds {
            var weaveArray: [[String:Any]] = []
            weaveIds .forEach { (weaveId) in
                var json: [String: Any] = [:]
                json["id"] = 0
                json["weaveId"] = weaveId
                weaveArray.append(json)
            }
            product["productWeaves"] = weaveArray
        }
        if let relatedProduct = relatedProduct {
            var arr: [[String:Any]] = []
            relatedProduct .forEach({ (info) in
                arr.append(info.toJSON())
            })
            product["relProduct"] = arr
        }
        return product
    }
}

struct relatedProductInfo {
    var productTypeId: Int?
    var width: String?
    var length: String?
    var weigth: String?
}

extension relatedProductInfo {
    func toJSON() -> [String: Any] {
        var product: [String: Any] = [:]
        
        if let productTypeId = productTypeId {
            product["productTypeId"] = productTypeId
        }
        if let width = width {
            product["width"] = width
        }
        if let length = length {
            product["length"] = length
        }
//        if let weigth = weigth {
//            product["weigth"] = weigth
//        }
        
        return product
    }
}

struct changeRequest {
    var changeRequestId: Int = 0
    var id: Int = 0
    var requestItemsId: Int = 0
    var requestStatus: Int = 0
    var requestText: String?
}

extension changeRequest {
    func toJSON() -> [String: Any] {

        var changeRequestJson: [String: Any] = [:]

        changeRequestJson["id"] = id
        changeRequestJson["changeRequestId"] = changeRequestId
        changeRequestJson["requestItemsId"] = requestItemsId
        changeRequestJson["requestStatus"] = requestStatus
        if let requestText = requestText {
            changeRequestJson["requestText"] = requestText
        }

        return changeRequestJson
    }
    
    func finalJson(eqId:Int, list:[changeRequest]) -> [String: Any] {
        var finalJson: [String: Any] = [:]
        finalJson["enquiryId"] = eqId
        var crArr: [[String: Any]] = []
        list .forEach { (cr) in
            crArr.append(cr.toJSON())
        }
        finalJson["itemList"] = crArr
        return finalJson
    }
}

struct qualityCheck {
    var stageId: Int = 0
    var enquiryId: Int = 0
    var saveOrSend: Int = 0
    var questionAnswers: [[String: Any]]?
}

extension qualityCheck {
    func toJSON() -> [String: Any] {

        var changeRequestJson: [String: Any] = [:]

        changeRequestJson["stageId"] = stageId
        changeRequestJson["enquiryId"] = enquiryId
        changeRequestJson["saveOrSend"] = saveOrSend
        changeRequestJson["questionAnswers"] = questionAnswers

        return changeRequestJson
    }
}
