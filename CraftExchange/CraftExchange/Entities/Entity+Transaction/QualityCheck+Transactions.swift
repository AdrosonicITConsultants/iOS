//
//  QualityCheck+Transactions.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension QualityCheck {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(QualityCheck.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.answer = answer
                object.modifiedOn = modifiedOn
                object.isSend = isSend
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

extension QCStages {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(QCStages.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.stage = stage
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

extension QCQuestions {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(QCQuestions.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.stageId = stageId
                object.questionNo = questionNo
                object.question = question
                object.answerType = answerType
                object.optionValue = optionValue
                object.isDelete = isDelete
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
