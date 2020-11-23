//
//  AdminUser+Transactions.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminUser {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminUser.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                firstName = object.firstName
                lastName = object.lastName
                rating = object.rating
                status = object.status
                email = object.email
                cluster = object.cluster
                brandName = object.brandName
                mobile = object.mobile
                dateAdded = object.dateAdded
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

