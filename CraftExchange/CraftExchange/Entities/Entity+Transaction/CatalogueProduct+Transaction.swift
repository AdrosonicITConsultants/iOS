//
//  CatalogueProduct+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 20/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension CatalogueProduct {
    
   static func getAllProductObjects() -> Results<CatalogueProduct> {
        let realm = try! Realm()
        let object = realm.objects(CatalogueProduct.self)
        return object
    }
    
    static func getProductObjects(searchId: Int) -> Results<CatalogueProduct> {
        let realm = try! Realm()
        let object = realm.objects(CatalogueProduct.self).filter("%K == %@", "productId", searchId)
        return object
    }
    
    func updateAddonDetails(userID: Int, isDeleted: Int) {
        let realm = try! Realm()
        if let object = realm.objects(CatalogueProduct.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.userID = userID
                object.isDeleted = isDeleted
            }
        }
    }
    
    static func setAllArtisanProductIsDeleteTrue() {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return
        }
        if let results = realm?.objects(CatalogueProduct.self).filter("%K == %@", "userID", userId) {
            try? realm?.write {
                results .forEach { (obj) in
                    obj.isDeleted = 1
                }
            }
        }
    }
    
    static func productIsDeleteTrue(forId: Int) {
           let realm = try? Realm()
           if let results = realm?.objects(CatalogueProduct.self).filter("%K == %@", "entityID", forId) {
               try? realm?.write {
                   results .forEach { (obj) in
                       obj.isDeleted = 1
                   }
               }
           }
       }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CatalogueProduct.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.availability = availability
                object.brand = brand
                object.category = category
                object.code = code
                object.count = count
                object.clusterName = clusterName
                object.dateAdded = dateAdded
                object.icon = icon
                object.images = images
                object.name = name
                object.orderGenerated = orderGenerated
                object.productId = productId
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }

}

extension SelectArtisanBrand {
    
   static func getAllArtisanObjects() -> Results<SelectArtisanBrand> {
        let realm = try! Realm()
        let object = realm.objects(SelectArtisanBrand.self)
        return object
    }
    
    static func getArtisanObjects(searchId: Int) -> Results<CatalogueProduct> {
        let realm = try! Realm()
        let object = realm.objects(CatalogueProduct.self).filter("%K == %@", "entityID", searchId)
        return object
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(SelectArtisanBrand.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.cluster = cluster
                object.brand = brand
                object.rating = rating
                object.weaverId = weaverId
                object.status = status
                object.email = email
                object.contact = contact
                object.state = state
                
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }

}
