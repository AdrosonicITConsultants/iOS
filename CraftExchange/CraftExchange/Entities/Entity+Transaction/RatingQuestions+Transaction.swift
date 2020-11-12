//
//  RatingQuestions+Transaction.swift
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

extension RatingQuestionsArtisan{
    static func getRatingType(searchId: String) -> RatingQuestionsArtisan? {
        let realm = try! Realm()
        if let object = realm.objects(RatingQuestionsArtisan.self).filter("%K == %@", "id", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(RatingQuestionsArtisan.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                
                object.question = question
                object.questionNo = questionNo
                object.type = type
                object.isDelete = isDelete
                object.createdOn = createdOn
                object.modifiedOn = modifiedOn
                object.answerType = answerType
               
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

extension RatingQuestionsBuyer {
    static func getRatingType(searchId: Int) -> RatingQuestionsBuyer? {
        let realm = try! Realm()
        if let object = realm.objects(RatingQuestionsBuyer.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(RatingQuestionsBuyer.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                   object.question = question
                   object.questionNo = questionNo
                   object.type = type
                   object.isDelete = isDelete
                   object.createdOn = createdOn
                   object.modifiedOn = modifiedOn
                   object.answerType = answerType
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}


