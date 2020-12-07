//
//  RatingResponse+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension RatingResponseArtisan{
    static func getRatingType(searchId: String) -> RatingResponseArtisan? {
        let realm = try! Realm()
        if let object = realm.objects(RatingResponseArtisan.self).filter("%K == %@", "id", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(RatingResponseArtisan.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                
                object.enquiryId = enquiryId
                object.questionId = questionId
                object.response = response
                object.responseComment = responseComment
                object.givenBy = givenBy
                object.givenTo = givenTo
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

extension RatingResponseBuyer {
    static func getRatingType(searchId: Int) -> RatingResponseBuyer? {
        let realm = try! Realm()
        if let object = realm.objects(RatingResponseBuyer.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(RatingResponseBuyer.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.enquiryId = enquiryId
                object.questionId = questionId
                object.response = response
                object.responseComment = responseComment
                object.givenBy = givenBy
                object.givenTo = givenTo
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


