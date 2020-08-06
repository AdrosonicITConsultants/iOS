//
//  ProductCare+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension ProductCare {
    static func getCareType(searchId: Int) -> ProductCare? {
        let realm = try! Realm()
        if let object = realm.objects(ProductCare.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ProductCare.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.productCareDesc = productCareDesc
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
