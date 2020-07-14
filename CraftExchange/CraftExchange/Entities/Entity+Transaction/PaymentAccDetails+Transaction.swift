//
//  PaymentAccDetails+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 14/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension PaymentAccDetails {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(PaymentAccDetails.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.name = name
                object.bankName = bankName
                object.branchName = branchName
                object.ifsc = ifsc
                object.AccNoUpiMobile = AccNoUpiMobile
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

