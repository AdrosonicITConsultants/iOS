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
            finalString.append(", \(state ?? "")")
        }
        if pincode != nil && pincode != "" {
            finalString.append(", \(pincode ?? "")")
        }
        if country.first?.name != nil && country.first?.name != "" {
            finalString.append("\n \(country.first?.name ?? "")")
        }
        return finalString
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Address.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.line1 = line1
                object.line2 = line2
                object.state = state
                object.street = street
                object.city = city
                object.district = district
                object.country = country
                object.pincode = pincode
                object.landmark = landmark
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
