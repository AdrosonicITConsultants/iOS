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
                if let cat = ProductCategory().getProductCat(catId: prod.productCategoryId ) {
                    prodCat.append(cat)
                }
            }
        }
        
        return prodCat
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Product.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                code = object.code
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
