//
//  Product+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 18/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension Product {
    
    func getAllProductCatForUser() -> [ProductCategory] {
        let realm = try! Realm()
        let objects = realm.objects(Product.self).filter("%K == %@", "artitionId", User.loggedIn()?.entityID ?? 0)
        var catIds: [Int] = []
        var prodCat: [ProductCategory] = []
        objects.forEach { (prod) in
            if !catIds.contains(prod.productCategoryId ) {
                catIds.append(prod.productCategoryId )
                if let cat = ProductCategory.getProductCat(catId: prod.productCategoryId ) {
                    prodCat.append(cat)
                }
            }
        }
        
        return prodCat
    }
    
    static func allArtisanProducts(for categoryId: Int) -> SafeSignal<Results<Product>> {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return Signal { observer in
                observer.receive(completion: .finished)
                return BlockDisposable {
                }
            }
        }
        return Signal { observer in
            if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId).filter("%K == %@", "productCategoryId", categoryId)
                .sorted(byKeyPath: "modifiedOn", ascending: false) {
                observer.receive(lastElement: results)
            } else {
                observer.receive(completion: .finished)
            }
            return BlockDisposable {
            }
        }
    }
    
    static func allProducts(categoryId: Int) -> SafeSignal<Results<Product>> {
        let realm = try? Realm()
        guard KeychainManager.standard.userID != nil else {
            return Signal { observer in
                observer.receive(completion: .finished)
                return BlockDisposable {
                }
            }
        }
        return Signal { observer in
            if let results = realm?.objects(Product.self).filter("%K == %@", "productCategoryId", categoryId).sorted(byKeyPath: "modifiedOn", ascending: false) {
                observer.receive(lastElement: results)
            } else {
                observer.receive(completion: .finished)
            }
            return BlockDisposable {
            }
        }
    }
    
    static func allProducts(clusterId: Int) -> SafeSignal<Results<Product>> {
        let realm = try? Realm()
        guard KeychainManager.standard.userID != nil else {
            return Signal { observer in
                observer.receive(completion: .finished)
                return BlockDisposable {
                }
            }
        }
        return Signal { observer in
            if let results = realm?.objects(Product.self).filter("%K == %@", "clusterId", clusterId)
                .sorted(byKeyPath: "modifiedOn", ascending: false) {
                observer.receive(lastElement: results)
            } else {
                observer.receive(completion: .finished)
            }
            return BlockDisposable {
            }
        }
    }
    
    static func allProducts(artisanId: Int) -> SafeSignal<Results<Product>> {
        let realm = try? Realm()
        guard KeychainManager.standard.userID != nil else {
            return Signal { observer in
                observer.receive(completion: .finished)
                return BlockDisposable {
                }
            }
        }
        return Signal { observer in
            if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", artisanId)
                .sorted(byKeyPath: "modifiedOn", ascending: false) {
                observer.receive(lastElement: results)
            } else {
                observer.receive(completion: .finished)
            }
            return BlockDisposable {
            }
        }
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Product.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.code = code
                object.productSpec = productSpec
                object.productDesc = productDesc
                object.productTag = productTag
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
                object.productStatusId = productStatusId
                object.gsm = gsm
                object.weight = weight
                object.createdOn = createdOn
                object.modifiedOn = modifiedOn
                object.isDeleted = isDeleted
                object.relatedProducts = relatedProducts
                object.productCategoryId = productCategoryId
                object.clusterId = clusterId
                
                let idsToCheck = productImages.compactMap { $0.entityID }
                var imgsToDelete: [ProductImage] = []
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
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    func syncChanges() {
        let realm = try? Realm()
        try? realm?.write {
            let messagesToAddOrUpdate = realm?.objects(Product.self).filter { $0.isDeleted == false }

            var emailUpdates: [Int: Product] = [:]
            let idsToCheck = messagesToAddOrUpdate?.compactMap { $0.entityID }
            let emailsPresent = realm?.objects(Product.self).filter("%K IN %@", "entityID", idsToCheck ?? [0])
            emailsPresent?.forEach({ (message) in
                emailUpdates[message.entityID] = message
            })

            messagesToAddOrUpdate?.forEach { (message) in
                if emailUpdates[message.entityID] == nil {
                    realm?.add(message, update: .modified)
                } else {
                    if let exisitingMessage = emailUpdates[message.entityID] {
                        exisitingMessage.code = message.code
                    }
                }
            }
            
            let messagesToDelete = realm?.objects(Product.self).filter { $0.isDeleted == true }
            let idsToBeDeleted = messagesToDelete?.compactMap { $0.entityID }
            if let emailsToDelete = realm?.objects(Product.self).filter("%K IN %@", "entityID", idsToBeDeleted ?? [0]) {
                realm?.delete(emailsToDelete)
            }
        }
    }
}
