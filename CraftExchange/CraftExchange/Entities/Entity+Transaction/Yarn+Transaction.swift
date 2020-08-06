//
//  Yarn+Transaction.swift
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

extension Yarn {
    static func getYarn(searchId: Int) -> Yarn? {
        let realm = try! Realm()
        if let object = realm.objects(Yarn.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Yarn.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.yarnDesc = yarnDesc
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
