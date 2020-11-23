//
//  AdminTeammate+Transaction.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension AdminTeammate {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(AdminTeammate.self).filter("%K == %@", "id", self.id).first {
            try? realm.write {
//                object.id = id
                object.username = username
                object.role = role
                object.email = email
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
}
