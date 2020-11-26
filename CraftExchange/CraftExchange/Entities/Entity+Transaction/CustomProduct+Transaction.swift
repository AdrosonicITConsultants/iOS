//
//  CustomProduct+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension CustomProduct {
    
    static func getCustomProduct(searchId: Int) -> CustomProduct? {
           let realm = try? Realm()
           if let object = realm?.objects(CustomProduct.self).filter("%K == %@", "entityID", searchId).first {
               return object
           }
           return nil
       }
    
    static func allBuyerProducts() -> SafeSignal<Results<CustomProduct>> {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return Signal { observer in
                observer.receive(completion: .finished)
                return BlockDisposable {
                }
            }
        }
        return Signal { observer in
            if let results = realm?.objects(CustomProduct.self).filter("%K == %@", "buyerId", userId).filter("%K == %@","isDeleted",false)
                .sorted(byKeyPath: "modifiedOn", ascending: false) {
                observer.receive(lastElement: results)
            } else {
                observer.receive(completion: .finished)
            }
            return BlockDisposable {
            }
        }
    }
    
    static func setAllBuyerProductsDeleteTrue() {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return
        }
        if let results = realm?.objects(CustomProduct.self).filter("%K == %@", "buyerId", userId) {
            try? realm?.write {
                results .forEach { (obj) in
                    obj.isDeleted = true
                }
            }
        }
    }
    
    static func deleteAllBuyerProductsWithIsDeleteTrue() {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return
        }
        if let results = realm?.objects(CustomProduct.self).filter("%K == %@", "buyerId", userId).filter("%K == %@","isDeleted",true) {
            try? realm?.write {
                realm?.delete(results)
            }
        }
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CustomProduct.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.productSpec = productSpec
                object.warpYarnId = warpYarnId
                object.weftYarnId = weftYarnId
                object.extraWeftYarnId = extraWeftYarnId
                object.warpYarnCount = warpYarnCount
                object.weftYarnCount = weftYarnCount
                object.extraWeftYarnCount = extraWeftYarnCount
                object.warpDyeId = warpDyeId
                object.weftDyeId = weftDyeId
                object.extraWeftDyeId = extraWeftDyeId
                object.length = length
                object.width = width
                object.reedCountId = reedCountId
                object.gsm = gsm
                object.createdOn = createdOn
                object.modifiedOn = modifiedOn
                object.isDeleted = isDeleted
                object.relatedProducts = relatedProducts
                object.productCategoryId = productCategoryId
                object.productTypeId = productTypeId
                
                let idsToCheck = productImages.compactMap { $0.entityID }
                var imgsToDelete: [CustomProductImage] = []
                object.productImages .forEach { (img) in
                    if !idsToCheck.contains(img.entityID) {
                        imgsToDelete.append(img)
                    }
                }
                realm.delete(imgsToDelete)
                
                let existingImgs = object.productImages.compactMap { $0.entityID }
                productImages .forEach { (img) in
                    if !existingImgs.contains(img.entityID) {
                        object.productImages.append(img)
                    }
                }
                
                let weaveIdsToCheck = weaves.compactMap { $0.entityId }
                var weavesToDelete: [CustomWeaveType] = []
                object.weaves .forEach { (obj) in
                    if !weaveIdsToCheck.contains(obj.entityId) {
                        weavesToDelete.append(obj)
                    }
                }
                realm.delete(weavesToDelete)
                
                let existingWeaves = object.weaves.compactMap { $0.entityId }
                weaves .forEach { (img) in
                    if !existingWeaves.contains(img.entityId) {
                        object.weaves.append(img)
                    }
                }
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}

