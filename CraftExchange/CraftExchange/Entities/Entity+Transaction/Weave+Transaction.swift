//
//  Weave+Transaction.swift
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

extension Weave {
    
    static func getWeaveType(searchId: Int) -> Weave? {
        let realm = try! Realm()
        if let object = realm.objects(Weave.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Weave.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.weaveDesc = weaveDesc 
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
