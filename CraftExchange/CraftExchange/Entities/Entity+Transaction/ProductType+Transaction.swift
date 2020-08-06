//
//  ProductType+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 03/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension ProductType {
    static func getProductType(searchId: Int) -> ProductType? {
        let realm = try! Realm()
        if let object = realm.objects(ProductType.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
}

