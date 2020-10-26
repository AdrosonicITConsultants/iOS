//
//  ChangeRequestType+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension ChangeRequestType {
    
    func searchChangeRequest(searchId: Int) -> ChangeRequestType? {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequestType.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequestType.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.item = item
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

