//
//  TransactionObject+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension TransactionObject {
    
    static func getAllTransactionObjects() -> Results<TransactionObject> {
        let realm = try! Realm()
        let object = realm.objects(TransactionObject.self)
        return object
    }
    
    static func getTransactionObjects(searchId: Int) -> Results<TransactionObject> {
        let realm = try! Realm()
        let object = realm.objects(TransactionObject.self).filter("%K == %@", "enquiryId", searchId).sorted(byKeyPath: "modifiedOn")
        return object
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(TransactionObject.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.accomplishedStatus = accomplishedStatus
                object.challanId = challanId
                object.completedOn = completedOn
                object.enquiryId = enquiryId
                object.isActionCompleted = isActionCompleted
                object.isActive = isActive
                object.modifiedOn = modifiedOn
                object.paidAmount = paidAmount
                object.paymentId = paymentId
                object.percentage = percentage
                object.piHistoryId = piHistoryId
                object.piId = piId
                object.receiptId = receiptId
                object.taxInvoiceId = taxInvoiceId
                object.totalAmount = totalAmount
                object.transactionOn = transactionOn
                object.upcomingStatus = upcomingStatus
                object.enquiryCode = enquiryCode
                object.orderCode = orderCode
                object.eta = eta
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
