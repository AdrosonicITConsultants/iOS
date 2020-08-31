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
    
    static func getSuggestedProduct(forProdId: Int, catId: Int, clusterID: Int) -> Results<Product>? {
        let realm = try? Realm()
        let objects = realm?.objects(Product.self).filter("%K != %@", "entityID",forProdId).filter("%K == %@","productCategoryId",catId).filter("%K == %@", "clusterId",clusterID)
        return objects
    }
    
    static public func getWishlistProducts() -> Results<Product>? {
        let realm = try? Realm()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let objects = realm?.objects(Product.self).filter("%K IN %@", "entityID",appDelegate?.wishlistIds ?? [0])
        return objects
    }
    
    static public func getSearchProducts(idList: [Int], madeWithAntaran: Int) -> SafeSignal<Results<Product>> {
        let realm = try? Realm()
        return Signal { observer in
            if madeWithAntaran == 0 {
                if let results = realm?.objects(Product.self).filter("%K IN %@", "entityID",idList) {
                    observer.receive(lastElement: results)
                } else {
                    observer.receive(completion: .finished)
                }
            }else {
                if let results = realm?.objects(Product.self).filter("%K IN %@", "entityID",idList).filter("%K == %@","madeWithAnthran", madeWithAntaran) {
                    observer.receive(lastElement: results)
                } else {
                    observer.receive(completion: .finished)
                }
            }
            
            return BlockDisposable {
            }
        }
    }
    
    static func getProduct(searchId: Int) -> Product? {
        let realm = try! Realm()
        if let object = realm.objects(Product.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func getAllProductCatForUser() -> [ProductCategory] {
        let realm = try! Realm()
        let objects = realm.objects(Product.self).filter("%K == %@", "artitionId", User.loggedIn()?.entityID ?? 0).filter("%K == %@","isDeleted",false)
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
            if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId).filter("%K == %@", "productCategoryId", categoryId).filter("%K == %@","isDeleted",false)
                .sorted(byKeyPath: "modifiedOn", ascending: false) {
                observer.receive(lastElement: results)
            } else {
                observer.receive(completion: .finished)
            }
            return BlockDisposable {
            }
        }
    }
    
    static func allArtisanProducts(for searchString: String, madeWithAntaran: Int) -> SafeSignal<Results<Product>> {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return Signal { observer in
                observer.receive(completion: .finished)
                return BlockDisposable {
                }
            }
        }
        if madeWithAntaran == 0 {
            return Signal { observer in
                if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId) {
                    let query = getQuery(searchString: searchString)
                    let finalResults = results.filter(query)
                    
                    observer.receive(lastElement: finalResults)
                }else {
                    observer.receive(completion: .finished)
                }
                return BlockDisposable {
                }
            }
        }else {
            return Signal { observer in
                if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId).filter("%K == %@","madeWithAnthran", madeWithAntaran) {
                    let finalQuery = getQuery(searchString: searchString)
                    let finalResults = results.filter(finalQuery)
                    observer.receive(lastElement: finalResults)
                }else {
                    observer.receive(completion: .finished)
                }
                return BlockDisposable {
                }
            }
        }
    }
    
    static func getQuery(searchString: String) -> NSCompoundPredicate {
        let prodTypeIds = ProductType.getProductType(searchString: searchString)
        let prodCatIds = ProductCategory.getProductCat(searchString: searchString)
        var finalQuery: NSCompoundPredicate
        let query = NSCompoundPredicate(type: .or, subpredicates:
            [NSPredicate(format: "code contains[c] %@",searchString),
             NSPredicate(format: "productTag contains[c] %@",searchString)])
        finalQuery = query
        if prodTypeIds?.count ?? 0 > 0 {
            let newQuery = NSCompoundPredicate(type: .or, subpredicates: [query,NSPredicate(format: "productTypeId IN %@", prodTypeIds!)])
            finalQuery = newQuery
        }
        if prodCatIds?.count ?? 0 > 0 {
            let newQuery = NSCompoundPredicate(type: .or, subpredicates: [finalQuery,NSPredicate(format: "productCategoryId IN %@", prodCatIds!)])
            finalQuery = newQuery
        }
        
        return finalQuery
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
            if let results = realm?.objects(Product.self).filter("%K == %@", "productCategoryId", categoryId).filter("%K == %@","isDeleted",false).sorted(byKeyPath: "modifiedOn", ascending: false) {
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
            if let results = realm?.objects(Product.self).filter("%K == %@", "clusterId", clusterId).filter("%K == %@","isDeleted",false)
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
            if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", artisanId).filter("%K == %@","isDeleted",false)
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
                object.productTypeId = productTypeId
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
                
                let careIdsToCheck = productCares.compactMap { $0.entityId }
                var caresToDelete: [ProductCareType] = []
                object.productCares .forEach { (obj) in
                    if !careIdsToCheck.contains(obj.entityId) {
                        caresToDelete.append(obj)
                    }
                }
                realm.delete(caresToDelete)
                
                let existingCares = object.productCares.compactMap { $0.entityId }
                productCares .forEach { (img) in
                    if !existingCares.contains(img.entityId) {
                        object.productCares.append(img)
                    }
                }
                
                let weaveIdsToCheck = weaves.compactMap { $0.entityId }
                var weavesToDelete: [WeaveType] = []
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
    
    func partialSaveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Product.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.code = code
                object.productSpec = productSpec
                object.productDesc = productDesc
                object.productTag = productTag
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    static func setAllArtisanProductIsDeleteTrue() {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return
        }
        if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId) {
            try? realm?.write {
                results .forEach { (obj) in
                    obj.isDeleted = true
                }
            }
        }
    }
    
    static func setAllArtisanProductIsDeleteFalse() {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return
        }
        if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId) {
            try? realm?.write {
                results .forEach { (obj) in
                    obj.isDeleted = false
                }
            }
        }
    }
    
    static func deleteAllArtisanProductsWithIsDeleteTrue() {
        let realm = try? Realm()
        guard let userId = KeychainManager.standard.userID else {
            return
        }
        if let results = realm?.objects(Product.self).filter("%K == %@", "artitionId", userId).filter("%K == %@","isDeleted",true) {
            try? realm?.write {
                realm?.delete(results)
            }
        }
    }
    
    static func productIsDeleteTrue(forId: Int) {
        let realm = try? Realm()
        if let results = realm?.objects(Product.self).filter("%K == %@", "entityID", forId) {
            try? realm?.write {
                results .forEach { (obj) in
                    obj.isDeleted = true
                }
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
