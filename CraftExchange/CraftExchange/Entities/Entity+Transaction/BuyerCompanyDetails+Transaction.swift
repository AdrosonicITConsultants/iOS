//
//  BuyerCompanyDetails+Transaction.swift
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

extension BuyerCompanyDetails {
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(BuyerCompanyDetails.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                companyName = object.companyName
                compDesc = object.compDesc
                logo = object.logo
                cin = object.cin
                gstNo = object.gstNo
                contact = object.contact
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
