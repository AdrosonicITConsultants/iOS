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
                designation = object.designation
                alternateMobile = object.alternateMobile
                buyerCompanyDetails = object.buyerCompanyDetails
                pointOfContact = object.pointOfContact
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
}
