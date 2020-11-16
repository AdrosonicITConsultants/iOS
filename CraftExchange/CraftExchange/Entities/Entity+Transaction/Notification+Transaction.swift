//
//  Notification+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 03/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension Notifications {
    
    func updateAddonDetails(userID: Int) {
        let realm = try! Realm()
        if let object = realm.objects(Notifications.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.userID = userID
                
            }
        }
    }

    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Notifications.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                
                object.code = code
                object.companyName = companyName
                object.createdOn = createdOn
                object.customProduct = customProduct
                object.details = details
                object.notificationTypeId = notificationTypeId
                object.productDesc = productDesc
                object.seen = seen
                object.type = type
               
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
