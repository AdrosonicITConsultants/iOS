//
//  TransactionStatus+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension TransactionStatus {
    
    static func getTransactionStatusType(searchId: Int) -> TransactionStatus? {
        let realm = try! Realm()
        if let object = realm.objects(TransactionStatus.self).filter("%K == %@", "transactionId", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(TransactionStatus.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.type = type
                object.viewType = viewType
                object.buyerText = buyerText
                object.artisanText = artisanText
                object.transactionStage = transactionStage
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
