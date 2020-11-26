//
//  AdminEscalation+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminEscalation {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminEscalation.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                date = object.date
                enquiryCode = object.enquiryCode
                artistBrand = object.artistBrand
                buyerBrand = object.buyerBrand
                stage = object.stage
                cluster = object.cluster
                lastUpdated = object.lastUpdated
                concern = object.concern
                price = object.price
                category = object.category
                raisedBy = object.raisedBy
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
