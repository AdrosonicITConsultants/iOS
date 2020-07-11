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
        if let prodCatId = productCategoryId {
            let realm = try? Realm()
            let result = realm?.objects(ProductCategory.self).filter("%K == %@", "entityID", prodCatId).first
            print("\n cat found \(result?.prodCatDescription ?? "Nope")")
            finalString = result?.prodCatDescription ?? ""
        }
        return finalString
    }
}
