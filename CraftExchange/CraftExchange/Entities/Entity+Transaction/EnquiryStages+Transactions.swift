//
//  EnquiryStages+Transactions.swift
//  CraftExchange
//
//  Created by Preety Singh on 12/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension EnquiryStages {
    static func getStageType(searchId: Int) -> EnquiryStages? {
        let realm = try! Realm()
        if let object = realm.objects(EnquiryStages.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(EnquiryStages.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.stageDescription = stageDescription
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
