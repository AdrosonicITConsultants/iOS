//
//  CompanyPointOfContact+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension CompanyPointOfContact {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CompanyPointOfContact.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                pocFirstName = object.pocFirstName
                pocLastName = object.pocLastName
                pocEmail = object.pocEmail
                pocContantNo = object.pocContantNo
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
