//
//  ClusterDetails+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension ClusterDetails {

    func saveOrUpdate() {
      let realm = try! Realm()
      if let object = realm.objects(ProductCategory.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
              clusterDescription = object.prodCatDescription
              self.prodCategory.forEach({prodCat in
                prodCat.saveOrUpdate()
              })
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
}

