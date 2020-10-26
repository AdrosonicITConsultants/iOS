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
    
    func searchChangeRequest(searchEqId: Int) -> ChangeRequest? {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequest.self).filter("%K == %@", "enquiryId", searchEqId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ChangeRequest.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.status = status
                object.createdOn = createdOn
                object.modifiedOn = modifiedOn
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
