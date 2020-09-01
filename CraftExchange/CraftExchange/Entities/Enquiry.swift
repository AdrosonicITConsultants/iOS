//
//  Enquiry.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Enquiry: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var userID: Int = 0
    @objc dynamic var enquiryStageId: Int = 0
    @objc dynamic var mobile: String?
    @objc dynamic var logo: String?
    @objc dynamic var startedOn: String?
    @objc dynamic var changeRequestOn: String?
    @objc dynamic var changeRequestStatus: String?
    @objc dynamic var changeRequestModifiedOn: String?
    @objc dynamic var enquiryCode: String?
    @objc dynamic var alternateMobile: String?
    @objc dynamic var orderCode: String?
    @objc dynamic var totalAmount: String?
    @objc dynamic var productCategoryId: Int = 0
    @objc dynamic var warpYarnId: Int = 0
    @objc dynamic var weftYarnId: Int = 0
    @objc dynamic var extraWeftYarnId: Int = 0
    @objc dynamic var companyName: String?
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var productStatusId: Int = 0
    @objc dynamic var productCode: String?
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var orderCreatedOn: String?
    @objc dynamic var productId: Int = 0
    @objc dynamic var email: String?
    @objc dynamic var isPiSend: String?
    @objc dynamic var enquiryStatusId: Int = 0
    @objc dynamic var pocFirstName: String?
    @objc dynamic var pocLastName: String?
    @objc dynamic var pocEmail: String?
    @objc dynamic var pocContact: String?
    @objc dynamic var gst: String?
    @objc dynamic var productHistoryCode: String?
    @objc dynamic var productHistoryName: String?
    @objc dynamic var productCategoryHistoryId: Int = 0
    @objc dynamic var warpYarnHistoryId: String?
    @objc dynamic var weftYarnHistoryId: String?
    @objc dynamic var innerEnquiryStageId: String?
    @objc dynamic var excpectedDate: String?
    @objc dynamic var isMoqSend: String?
    @objc dynamic var productType: String?
    @objc dynamic var productImages: String?
    @objc dynamic var extraWeftYarnHistoryId: Int = 0
    @objc dynamic var productStatusHistoryId: Int = 0
    @objc dynamic var madeWittAnthranHistory: Int = 0
    @objc dynamic var pincode: String?
    @objc dynamic var district: String?
    @objc dynamic var line1: String?
    @objc dynamic var line2: String?
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var lastUpdated: String?
    @objc dynamic var productName: String?
    @objc dynamic var historyProductId: Int = 0
    @objc dynamic var madeWittAnthran: Int = 0
    @objc dynamic var productHistoryImages: String?
    @objc dynamic var state: String?
    @objc dynamic var country: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case mobile = "mobile"
        case logo = "logo"
        case startedOn = "startedOn"
        case enquiryStageId = "enquiryStageId"
        case changeRequestOn = "changeRequestOn"
        case changeRequestStatus = "changeRequestStatus"
        case changeRequestModifiedOn = "changeRequestModifiedOn"
        case enquiryCode = "enquiryCode"
        case alternateMobile = "alternateMobile"
        case orderCode = "orderCode"
        case totalAmount = "totalAmount"
        case productCategoryId = "productCategoryId"
        case warpYarnId = "warpYarnId"
        case weftYarnId = "weftYarnId"
        case extraWeftYarnId = "extraWeftYarnId"
        case companyName = "companyName"
        case firstName = "firstName"
        case lastName = "lastName"
        case productStatusId = "productStatusId"
        case productCode = "productCode"
        case enquiryId = "enquiryId"
        case orderCreatedOn = "orderCreatedOn"
        case productId = "productId"
        case email = "email"
        case isPiSend = "isPiSend"
        case enquiryStatusId = "enquiryStatusId"
        case pocFirstName = "pocFirstName"
        case pocLastName = "pocLastName"
        case pocEmail = "pocEmail"
        case pocContact = "pocContact"
        case gst = "gst"
        case productHistoryCode = "productHistoryCode"
        case productHistoryName = "productHistoryName"
        case productCategoryHistoryId = "productCategoryHistoryId"
        case warpYarnHistoryId = "warpYarnHistoryId"
        case weftYarnHistoryId = "weftYarnHistoryId"
        case innerEnquiryStageId = "innerEnquiryStageId"
        case excpectedDate = "excpectedDate"
        case isMoqSend = "isMoqSend"
        case productType = "productType"
        case productImages = "productImages"
        case extraWeftYarnHistoryId = "extraWeftYarnHistoryId"
        case productStatusHistoryId = "productStatusHistoryId"
        case madeWittAnthranHistory = "madeWittAnthranHistory"
        case pincode = "pincode"
        case district = "district"
        case line1 = "line1"
        case line2 = "line2"
        case street = "street"
        case city = "city"
        case state = "state"
        case country = "country"
        case landmark = "landmark"
        case lastUpdated = "lastUpdated"
        case productName = "productName"
        case historyProductId = "historyProductId"
        case madeWittAnthran = "madeWittAnthran"
        case productHistoryImages = "productHistoryImages"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        enquiryStageId = try (values.decodeIfPresent(Int.self, forKey: .enquiryStageId) ?? 0)
        mobile = try? values.decodeIfPresent(String.self, forKey: .mobile)
        logo = try? values.decodeIfPresent(String.self, forKey: .logo)
        startedOn = try? values.decodeIfPresent(String.self, forKey: .startedOn)
        changeRequestOn = try? values.decodeIfPresent(String.self, forKey: .changeRequestOn)
        changeRequestStatus = try? values.decodeIfPresent(String.self, forKey: .changeRequestStatus)
        changeRequestModifiedOn = try? values.decodeIfPresent(String.self, forKey: .changeRequestModifiedOn)
        enquiryCode = try? values.decodeIfPresent(String.self, forKey: .enquiryCode)
        alternateMobile = try? values.decodeIfPresent(String.self, forKey: .alternateMobile)
    }
}

