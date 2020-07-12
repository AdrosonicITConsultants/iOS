//
//  User+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension User {
    
    static func loggedIn() -> User? {
        guard let userID = KeychainManager.standard.userID else { return nil }
        let realm = try? Realm()
        return realm?.objects(User.self).filter("%K == %@", "entityID", userID).first
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.designation = designation
                object.alternateMobile = alternateMobile
                object.buyerCompanyDetails = buyerCompanyDetails
                object.pointOfContact = pointOfContact
                object.paymentAccountList = paymentAccountList
                object.userProductCategories = userProductCategories
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
    
    func saveOrUpdateProfileImage(data: Data) {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                try Disk.save(data, to: .caches, as: "\(entityID)/\(profilePic ?? "download.jpg")")
                profilePicUrl = try? Disk.retrieveURL("\(entityID)/\(profilePic ?? "download.jpg")", from: .caches, as: Data.self).absoluteString
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
    
    func saveOrUpdateBrandLogo(data: Data) {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                try Disk.save(data, to: .caches, as: "\(entityID)/\(logo ?? "download.jpg")")
                logoUrl = try? Disk.retrieveURL("\(entityID)/\(logo ?? "download.jpg")", from: .caches, as: Data.self).absoluteString
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
}
