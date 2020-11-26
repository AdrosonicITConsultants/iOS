//
//  AdminRedirectEnquiry+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminRedirectEnquiry {
    
    func updateAddonDetails(typeId: Int) {
        let realm = try! Realm()
        if let object = realm.objects(AdminRedirectEnquiry.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.typeId = typeId
            }
        }
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminRedirectEnquiry.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.code = code
                object.companyName = companyName
                object.date = date
                object.productCategory = productCategory
                object.productId = productId
                object.weave = weave
                
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }

}
