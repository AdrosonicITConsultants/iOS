//
//  AdminRoles+Transaction.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 21/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminRoles {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminRoles.self).filter("%K == %@", "id", self.id).first {
            try? realm.write {
//                object.id = id
                object.desc = desc
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
}
