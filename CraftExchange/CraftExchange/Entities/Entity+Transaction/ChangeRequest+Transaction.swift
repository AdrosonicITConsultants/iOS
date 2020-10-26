//
//  ChangeRequest+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension ChangeRequest {
    
    func searchChangeRequest(searchId: Int) -> ChangeRequest? {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequest.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequest.self).filter("%K == %@", "entityID", self.entityID).first {
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
