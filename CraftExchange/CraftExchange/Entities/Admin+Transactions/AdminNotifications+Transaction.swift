//
//  AdminNotifications+Transaction.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminNotifications {

    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminNotifications.self).filter("%K == %@", "notificationId", self.notificationId).first {
            try? realm.write {
                object.code = code
                object.createdOn = createdOn
                object.notificationType = notificationType
                object.productDesc = productDesc
               
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
