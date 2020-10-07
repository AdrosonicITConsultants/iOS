//
//  MOQDeliveryTimes+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 18/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension EnquiryMOQDeliveryTimes {
    
    static func getDeliveryType(TimeId: Int) -> EnquiryMOQDeliveryTimes? {
        let realm = try! Realm()
        if let object = realm.objects(EnquiryMOQDeliveryTimes.self).filter("%K == %@", "entityID", TimeId).first {
            return object
        }
        return nil
    }
    
    static func getDeliveryTime(searchString: String) -> [Int]? {
        let realm = try? Realm()
        if let object = realm?.objects(EnquiryMOQDeliveryTimes.self).filter("%K == %@", "deliveryDesc", searchString) {
            return object.compactMap({ $0.entityID })
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(EnquiryMOQDeliveryTimes.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.deliveryDesc = deliveryDesc
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

