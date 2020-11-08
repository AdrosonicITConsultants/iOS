//
//  Chat+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension Chat {
    
    static func getAllChatObjects() -> Results<Chat> {
        let realm = try! Realm()
        let object = realm.objects(Chat.self)
        return object
    }
    
    func searchChat(searchId: Int) -> Chat? {
        let realm = try! Realm()
        if let object = realm.objects(Chat.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveRecord() {
        let realm = try? Realm()
        if let _ = realm?.objects(Chat.self).filter("%K == %@", "entityID", self.entityID).first {
        }else {
            try? realm?.write {
                realm?.add(self, update: .modified)
            }
        }
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Chat.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.buyerCompanyName = buyerCompanyName
                object.buyerId = buyerId
                object.buyerLogo = buyerLogo
                object.changeRequestDone = changeRequestDone
                object.convertedToOrderDate = convertedToOrderDate
                object.enquiryGeneratedOn = enquiryGeneratedOn
                object.enquiryId = enquiryId
                object.enquiryNumber = enquiryNumber
                object.escalation = escalation
                object.lastChatDate = lastChatDate
                object.lastUpdatedOn = lastUpdatedOn
                object.orderAmount = orderAmount
                object.orderReceiveDate = orderReceiveDate
                object.orderStatus = orderStatus
                object.orderStatusId = orderStatusId
                object.productTypeId = productTypeId
                object.unreadMessage = unreadMessage
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

extension Conversation {
    
    func searchChat(searchId: Int) -> Conversation? {
        let realm = try! Realm()
        if let object = realm.objects(Conversation.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func saveRecord() {
        let realm = try? Realm()
        if let _ = realm?.objects(Conversation.self).filter("%K == %@", "entityID", self.entityID).first {
        }else {
            try? realm?.write {
                realm?.add(self, update: .modified)
            }
        }
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Conversation.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.createdOn = createdOn
                object.enquiryId = enquiryId
              //  object.id = id
                object.isDelete = isDelete
                object.mediaName = mediaName
                object.mediaType = mediaType
                object.messageFrom = messageFrom
                object.messageString = messageString
                object.messageTo = messageTo
                object.path = path
                object.seen = seen
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
