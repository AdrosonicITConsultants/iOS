//
//  Country+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 06/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension Country {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Country.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                name = object.name
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
}
