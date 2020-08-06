//
//  ReedCount+Transaction.swift
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

extension ReedCount {
    static func getReedCount(searchId: Int) -> ReedCount? {
        let realm = try! Realm()
        if let object = realm.objects(ReedCount.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ReedCount.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.count = count
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
