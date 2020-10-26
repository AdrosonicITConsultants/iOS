//
//  ChangeRequestItem+Transaction.swift
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

extension ChangeRequestItem {
    
    func searchChangeRequestItems(searchId: Int) -> Results<ChangeRequestItem>? {
        let realm = try! Realm()
        let object = realm.objects(ChangeRequestItem.self).filter("%K == %@", "changeRequestId", searchId)
        return object
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequestItem.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.requestStatus = requestStatus
                object.requestText = requestText
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

