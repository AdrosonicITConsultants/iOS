//
//  ProductCategory+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension ProductCategory {
    
    static func getProductCat(catId: Int) -> ProductCategory? {
        let realm = try! Realm()
        if let object = realm.objects(ProductCategory.self).filter("%K == %@", "entityID", catId).first {
            return object
        }
        return nil
    }

    func saveOrUpdate() {
      let realm = try! Realm()
      if let object = realm.objects(ProductCategory.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
              prodCatDescription = object.prodCatDescription
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
