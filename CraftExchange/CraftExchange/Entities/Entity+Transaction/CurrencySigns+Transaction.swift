//
//  CurrencySigns+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 30/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension CurrencySigns {
    
    static func getCurrencyType(CurrencyId: Int) -> CurrencySigns? {
        let realm = try! Realm()
        if let object = realm.objects(CurrencySigns.self).filter("%K == %@", "entityID", CurrencyId).first {
            return object
        }
        return nil
    }
    
    static func getCurrencySymbol(searchString: String) -> [Int]? {
        let realm = try? Realm()
        if let object = realm?.objects(CurrencySigns.self).filter("%K == %@", "sign", searchString) {
            return object.compactMap({ $0.entityID })
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CurrencySigns.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.sign = sign
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

