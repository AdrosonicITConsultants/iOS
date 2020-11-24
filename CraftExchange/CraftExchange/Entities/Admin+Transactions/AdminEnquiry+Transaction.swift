//
//  AdminEnquiry+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminEnquiry {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminEnquiry.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                amount = object.amount
                artisanBrand = object.artisanBrand
                artisanId = object.artisanId
                buyerBrand = object.buyerBrand
                buyerId = object.buyerId
                cluster = object.cluster
                code = object.code
                currenStage = object.currenStage
                currenStageId = object.currenStageId
                customProductHistoryId = object.customProductHistoryId
                customProductId = object.customProductId
                dateStarted = object.dateStarted
                eta = object.eta
                historyTag = object.historyTag
                innerCurrenStage = object.innerCurrenStage
                innerCurrenStageId = object.innerCurrenStageId
                lastUpdated = object.lastUpdated
                madeWithAntharan = object.madeWithAntharan
                productHistoryId = object.productHistoryId
                productHistoryStatus = object.productHistoryStatus
                productId = object.productId
                productStatus = object.productStatus
                tag = object.tag
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
