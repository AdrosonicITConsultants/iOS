//
//  Order.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Order: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var enquiryStageId: Int = 0
    @objc dynamic var mobile: String?
    @objc dynamic var logo: String?
    @objc dynamic var startedOn: String?
    @objc dynamic var isReprocess: Int = 0
    @objc dynamic var artisanReviewId: String?
    @objc dynamic var changeRequestOn: Int = 0
    @objc dynamic var changeRequestStatus: Int = 0
    @objc dynamic var changeRequestModifiedOn: Date?
    @objc dynamic var enquiryCode: String?
    @objc dynamic var alternateMobile: String?
    @objc dynamic var orderCode: String?
    @objc dynamic var totalAmount: Int = 0
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
    @objc dynamic var orderCreatedOn: Date?
    @objc dynamic var productId: Int = 0
    @objc dynamic var email: String?
    @objc dynamic var isPiSend: Int = 0
    @objc dynamic var enquiryStatusId: Int = 0
    @objc dynamic var pocFirstName: String?
    @objc dynamic var pocLastName: String?
    @objc dynamic var pocEmail: String?
    @objc dynamic var pocContact: String?
    @objc dynamic var gst: String?
    @objc dynamic var deliveryChallanUploaded: Int = 0
    @objc dynamic var deliveryChallanLabel: String?
    @objc dynamic var isPartialRefundReceived: Int = 1
    @objc dynamic var productHistoryCode: String?
    @objc dynamic var productHistoryName: String?
    @objc dynamic var productCategoryHistoryId: Int = 0
    @objc dynamic var warpYarnHistoryId: Int = 0
    @objc dynamic var weftYarnHistoryId: Int = 0
    @objc dynamic var innerEnquiryStageId: Int = 0
    @objc dynamic var expectedDate: Date?
    @objc dynamic var isMoqSend: Int = 0
    @objc dynamic var productType: String?
    @objc dynamic var productImages: String?
    @objc dynamic var extraWeftYarnHistoryId: Int = 0
    @objc dynamic var productStatusHistoryId: Int = 0
    @objc dynamic var madeWithAnthranHistory: Int = 0
    @objc dynamic var pincode: String?
    @objc dynamic var district: String?
    @objc dynamic var line1: String?
    @objc dynamic var line2: String?
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var lastUpdated: Date?
    @objc dynamic var productName: String?
    @objc dynamic var historyProductId: Int = 0
    @objc dynamic var madeWithAnthran: Int = 0
    @objc dynamic var productHistoryImages: String?
    @objc dynamic var state: String?
    @objc dynamic var country: String?
    @objc dynamic var comment: String?
    @objc dynamic var eqDescription: String?
    @objc dynamic var brandName: String?
    @objc dynamic var isBlue: Bool = false
    @objc dynamic var isMoqRejected: Bool = false
    @objc dynamic var orderReceiveDate: Date?
    @objc dynamic var profilePic: String?
    @objc dynamic var userId: Int = 0
    @objc dynamic var clusterName: String?
    var paymentAccountList = List<PaymentAccDetails>()
    var productCategories: [Int] = []
    
    enum CodingKeys: String, CodingKey {
//        case id = "id"
        case mobile = "mobile"
        case logo = "logo"
        case startedOn = "startedOn"
        case enquiryStageId = "enquiryStageId"
        case changeRequestOn = "changeRequestOn"
        case changeRequestStatus = "changeRequestStatus"
        case changeRequestModifiedOn = "changeRequestModifiedOn"
        case isReprocess = "isReprocess"
        case artisanReviewId = "artisanReviewId"
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
        case deliveryChallanUploaded = "deliveryChallanUploaded"
        case deliveryChallanLabel = "deliveryChallanLabel"
        case isPartialRefundReceived = "isPartialRefundReceived"
        case productHistoryCode = "productHistoryCode"
        case productHistoryName = "productHistoryName"
        case productCategoryHistoryId = "productCategoryHistoryId"
        case warpYarnHistoryId = "warpYarnHistoryId"
        case weftYarnHistoryId = "weftYarnHistoryId"
        case innerEnquiryStageId = "innerEnquiryStageId"
        case expectedDate = "excpectedDate"
        case isMoqSend = "isMoqSend"
        case productType = "productType"
        case productImages = "productImages"
        case extraWeftYarnHistoryId = "extraWeftYarnHistoryId"
        case productStatusHistoryId = "productStatusHistoryId"
        case madeWithAnthranHistory = "madeWittAnthranHistory"
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
        case madeWithAnthran = "madeWittAnthran"
        case productHistoryImages = "productHistoryImages"
        case comment = "comment"
        case eqDescription = "description"
        case orderReceiveDate = "orderReceiveDate"
        case profilePic = "profilePic"
        case paymentAccountDetails = "paymentAccountDetails"
        case productCategories = "productCategories"
        case clusterName = "clusterName"
        case isBlue = "isBlue"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        id = "\(entityID)"
        alternateMobile = try? values.decodeIfPresent(String.self, forKey: .alternateMobile)
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .changeRequestModifiedOn) {
            changeRequestModifiedOn = Date().ttceISODate(isoDate: dateString)
        }
        isReprocess = try (values.decodeIfPresent(Int.self, forKey: .isReprocess) ?? 0)
        artisanReviewId = try? values.decodeIfPresent(String.self, forKey: .artisanReviewId)
        changeRequestOn = try (values.decodeIfPresent(Int.self, forKey: .changeRequestOn) ?? 0)
        changeRequestStatus = try (values.decodeIfPresent(Int.self, forKey: .changeRequestStatus) ?? 0)
        city = try? values.decodeIfPresent(String.self, forKey: .city)
        comment = try? values.decodeIfPresent(String.self, forKey: .comment)
        companyName = try? values.decodeIfPresent(String.self, forKey: .companyName)
        country = try? values.decodeIfPresent(String.self, forKey: .country)
        eqDescription = try? values.decodeIfPresent(String.self, forKey: .eqDescription)
        district = try? values.decodeIfPresent(String.self, forKey: .district)
        email = try? values.decodeIfPresent(String.self, forKey: .email)
        enquiryCode = try? values.decodeIfPresent(String.self, forKey: .enquiryCode)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        enquiryStageId = try (values.decodeIfPresent(Int.self, forKey: .enquiryStageId) ?? 0)
        enquiryStatusId = try (values.decodeIfPresent(Int.self, forKey: .enquiryStatusId) ?? 0)
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .expectedDate) {
            expectedDate = Date().ttceISODate(isoDate: dateString)
        }
        extraWeftYarnHistoryId = try (values.decodeIfPresent(Int.self, forKey: .extraWeftYarnHistoryId) ?? 0)
        extraWeftYarnId = try (values.decodeIfPresent(Int.self, forKey: .extraWeftYarnId) ?? 0)
        firstName = try? values.decodeIfPresent(String.self, forKey: .firstName)
        gst = try? values.decodeIfPresent(String.self, forKey: .gst)
        deliveryChallanUploaded = try (values.decodeIfPresent(Int.self, forKey: .deliveryChallanUploaded) ?? 0)
        deliveryChallanLabel = try? values.decodeIfPresent(String.self, forKey: .deliveryChallanLabel)
        isPartialRefundReceived = try (values.decodeIfPresent(Int.self, forKey: .isPartialRefundReceived) ?? 1)
        historyProductId = try (values.decodeIfPresent(Int.self, forKey: .historyProductId) ?? 0)
        innerEnquiryStageId = try (values.decodeIfPresent(Int.self, forKey: .innerEnquiryStageId) ?? 0)
        isMoqSend = try (values.decodeIfPresent(Int.self, forKey: .isMoqSend) ?? 0)
        isPiSend = try (values.decodeIfPresent(Int.self, forKey: .isPiSend) ?? 0)
        lastName = try? values.decodeIfPresent(String.self, forKey: .lastName)
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .lastUpdated) {
            lastUpdated = Date().ttceISODate(isoDate: dateString)
        }
        line1 = try? values.decodeIfPresent(String.self, forKey: .line1)
        line2 = try? values.decodeIfPresent(String.self, forKey: .line2)
        logo = try? values.decodeIfPresent(String.self, forKey: .logo)
        madeWithAnthran = try (values.decodeIfPresent(Int.self, forKey: .madeWithAnthran) ?? 0)
        madeWithAnthranHistory = try (values.decodeIfPresent(Int.self, forKey: .madeWithAnthranHistory) ?? 0)
        mobile = try? values.decodeIfPresent(String.self, forKey: .mobile)
        orderCode = try? values.decodeIfPresent(String.self, forKey: .orderCode)
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .orderCreatedOn) {
            orderCreatedOn = Date().ttceISODate(isoDate: dateString)
        }
        if let dateString = try? values.decodeIfPresent(String.self, forKey: .orderReceiveDate) {
            orderReceiveDate = Date().ttceISODate(isoDate: dateString)
        }
        pincode = try? values.decodeIfPresent(String.self, forKey: .pincode)
        pocContact = try? values.decodeIfPresent(String.self, forKey: .pocContact)
        pocEmail = try? values.decodeIfPresent(String.self, forKey: .pocEmail)
        pocFirstName = try? values.decodeIfPresent(String.self, forKey: .pocFirstName)
        pocLastName = try? values.decodeIfPresent(String.self, forKey: .pocLastName)
        productCategoryHistoryId = try (values.decodeIfPresent(Int.self, forKey: .productCategoryHistoryId) ?? 0)
        productCategoryId = try (values.decodeIfPresent(Int.self, forKey: .productCategoryId) ?? 0)
        productCode = try? values.decodeIfPresent(String.self, forKey: .productCode)
        productHistoryCode = try? values.decodeIfPresent(String.self, forKey: .productHistoryCode)
        productHistoryImages = try? values.decodeIfPresent(String.self, forKey: .productHistoryImages)
        productHistoryName = try? values.decodeIfPresent(String.self, forKey: .productHistoryName)
        productId = try (values.decodeIfPresent(Int.self, forKey: .productId) ?? 0)
        productImages = try? values.decodeIfPresent(String.self, forKey: .productImages)
        productName = try? values.decodeIfPresent(String.self, forKey: .productName)
        productStatusHistoryId = try (values.decodeIfPresent(Int.self, forKey: .productStatusHistoryId) ?? 0)
        productStatusId = try (values.decodeIfPresent(Int.self, forKey: .productStatusId) ?? 0)
        productType = try? values.decodeIfPresent(String.self, forKey: .productType)
        profilePic = try? values.decodeIfPresent(String.self, forKey: .profilePic)
        startedOn = try? values.decodeIfPresent(String.self, forKey: .startedOn)
        state = try? values.decodeIfPresent(String.self, forKey: .state)
        street = try? values.decodeIfPresent(String.self, forKey: .street)
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        warpYarnHistoryId = try (values.decodeIfPresent(Int.self, forKey: .warpYarnHistoryId) ?? 0)
        warpYarnId = try (values.decodeIfPresent(Int.self, forKey: .warpYarnId) ?? 0)
        weftYarnHistoryId = try (values.decodeIfPresent(Int.self, forKey: .weftYarnHistoryId) ?? 0)
        weftYarnId = try (values.decodeIfPresent(Int.self, forKey: .weftYarnId) ?? 0)
        if let blue = try (values.decodeIfPresent(Int.self, forKey: .isBlue)) {
            isBlue = blue == 1 ? true : false
        }
        if let list = try? values.decodeIfPresent([PaymentAccDetails].self, forKey: .paymentAccountDetails) {
            paymentAccountList.append(objectsIn: list)
        }
        if let list = try? values.decodeIfPresent([UserProductCategory].self, forKey: .productCategories) {
            productCategories.append(contentsOf: list.compactMap({ $0.productCategoryId }))
        }
        clusterName = try? values.decodeIfPresent(String.self, forKey: .clusterName)
    }
}
