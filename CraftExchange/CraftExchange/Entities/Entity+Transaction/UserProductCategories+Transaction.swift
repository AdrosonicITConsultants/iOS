//
//  UserProductCategories+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension UserProductCategory {
    
    var categoryString: String {
        var finalString = ""
        let realm = try? Realm()
        let result = realm?.objects(ProductCategory.self).filter("%K == %@", "entityID", productCategoryId).first
        print("\n cat found \(result?.prodCatDescription ?? "Nope")")
        finalString = result?.prodCatDescription ?? ""
        return finalString
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(UserProductCategory.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.userId = userId
                object.productCategoryId = productCategoryId
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
