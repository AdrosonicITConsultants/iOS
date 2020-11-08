//
//  FaultyOrderReview+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 03/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension ArtisanFaultyOrder {
    static func getReviewType(searchId: String) -> ArtisanFaultyOrder? {
        let realm = try! Realm()
        if let object = realm.objects(ArtisanFaultyOrder.self).filter("%K == %@", "id", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(ArtisanFaultyOrder.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.comment = comment
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

extension BuyerFaultyOrder {
    static func getReviewType(searchId: Int) -> BuyerFaultyOrder? {
        let realm = try! Realm()
        if let object = realm.objects(BuyerFaultyOrder.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(BuyerFaultyOrder.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.comment = comment
                 object.subComment = subComment
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

