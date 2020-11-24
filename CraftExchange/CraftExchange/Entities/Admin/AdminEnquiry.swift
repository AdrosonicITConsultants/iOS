//
//  AdminEnquiry.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AdminEnquiry: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var entityID: Int = 0
    @objc dynamic var amount: Int = 0
    @objc dynamic var artisanBrand: String?
    @objc dynamic var artisanId: Int = 0
    @objc dynamic var buyerBrand: String?
    @objc dynamic var buyerId: Int = 0
    @objc dynamic var cluster: String?
    @objc dynamic var code: String?
    @objc dynamic var currenStage: String?
    @objc dynamic var currenStageId: Int = 0
    @objc dynamic var customProductHistoryId: Int = 0
    @objc dynamic var customProductId: Int = 0
    @objc dynamic var dateStarted: Date?
    @objc dynamic var eta: String?
    @objc dynamic var historyTag: String?
    @objc dynamic var innerCurrenStage: String?
    @objc dynamic var innerCurrenStageId: Int = 0
    @objc dynamic var lastUpdated: Date?
    @objc dynamic var madeWithAntharan: Int = 0
    @objc dynamic var productHistoryId: Int = 0
    @objc dynamic var productHistoryStatus: Int = 0
    @objc dynamic var productId: Int = 0
    @objc dynamic var productStatus: Int = 0
    @objc dynamic var tag: String?

    enum CodingKeys: String, CodingKey {
        case id = "eId"
        case amount = "amount"
        case artisanBrand = "artisanBrand"
        case artisanId = "artisanId"
        case buyerBrand = "buyerBrand"
        case buyerId = "buyerId"
        case cluster = "cluster"
        case code = "code"
        case currenStage = "currenStage"
        case currenStageId = "currenStageId"
        case customProductHistoryId = "customProductHistoryId"
        case customProductId = "customProductId"
        case dateStarted = "dateStarted"
        case eta = "eta"
        case historyTag = "historyTag"
        case innerCurrenStage = "innerCurrenStage"
        case innerCurrenStageId = "innerCurrenStageId"
        case lastUpdated = "lastUpdated"
        case madeWithAntharan = "madeWithAntharan"
        case productHistoryId = "productHistoryId"
        case productHistoryStatus = "productHistoryStatus"
        case productId = "productId"
        case productStatus = "productStatus"
        case tag = "tag"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        id = "\(entityID)"
        amount = try values.decodeIfPresent(Int.self, forKey: .amount) ?? 0
        artisanBrand = try? values.decodeIfPresent(String.self, forKey: .artisanBrand)
        artisanId = try values.decodeIfPresent(Int.self, forKey: .artisanId) ?? 0
        buyerBrand = try? values.decodeIfPresent(String.self, forKey: .buyerBrand)
        buyerId = try values.decodeIfPresent(Int.self, forKey: .buyerId) ?? 0
        cluster = try? values.decodeIfPresent(String.self, forKey: .cluster)
        code = try? values.decodeIfPresent(String.self, forKey: .code)
        currenStage = try? values.decodeIfPresent(String.self, forKey: .currenStage)
        currenStageId = try (values.decodeIfPresent(Int.self, forKey: .currenStageId) ?? 0)
        customProductHistoryId = try (values.decodeIfPresent(Int.self, forKey: .customProductHistoryId) ?? 0)
        customProductId = try (values.decodeIfPresent(Int.self, forKey: .customProductId) ?? 0)
        if let date = try? values.decodeIfPresent(String.self, forKey: .dateStarted) {
            dateStarted = Date().ttceISODate(isoDate: date)
        }
        eta = try? values.decodeIfPresent(String.self, forKey: .eta)
        historyTag = try? values.decodeIfPresent(String.self, forKey: .historyTag)
        innerCurrenStage = try? values.decodeIfPresent(String.self, forKey: .innerCurrenStage)
        innerCurrenStageId = try (values.decodeIfPresent(Int.self, forKey: .innerCurrenStageId) ?? 0)
        if let date = try? values.decodeIfPresent(String.self, forKey: .lastUpdated) {
            lastUpdated = Date().ttceISODate(isoDate: date)
        }
        madeWithAntharan = try (values.decodeIfPresent(Int.self, forKey: .madeWithAntharan) ?? 0)
        productHistoryId = try (values.decodeIfPresent(Int.self, forKey: .productHistoryId) ?? 0)
        productHistoryStatus = try (values.decodeIfPresent(Int.self, forKey: .productHistoryStatus) ?? 0)
        productId = try (values.decodeIfPresent(Int.self, forKey: .productId) ?? 0)
        productStatus = try (values.decodeIfPresent(Int.self, forKey: .productStatus) ?? 0)
        tag = try? values.decodeIfPresent(String.self, forKey: .tag)
    }
}
