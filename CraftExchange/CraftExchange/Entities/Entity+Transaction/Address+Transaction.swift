//
//  Address+Transaction.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension Address {
    
    var addressString: String {
        var finalString = ""
        if line1 != nil && line1 != "" {
            finalString.append(line1 ?? "")
        }
        if line2 != nil && line2 != "" {
            finalString.append(" \(line2 ?? "")")
        }
        if street != nil && street != "" {
            finalString.append(", \(street ?? "")")
        }
        if city != nil && city != "" {
            finalString.append(city ?? "")
        }
        if district != nil && district != "" {
            finalString.append(" \(district ?? "")")
        }
        if state != nil && state != "" {
            finalString.append(", \(street ?? "")")
        }
        if pincode != nil && pincode != "" {
            finalString.append(", \(pincode ?? "")")
        }
        if country?.name != nil && country?.name != "" {
            finalString.append("\n \(country?.name ?? "")")
        }
        return finalString
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Address.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                line1 = object.line1
                line2 = object.line2
                state = object.state
                street = object.street
                city = object.city
                district = object.district
                country = object.country
                pincode = object.pincode
                landmark = object.landmark
            }
        } else {
            try? realm.write {
                realm.add(self)
            }
        }
    }
}
