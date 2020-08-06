//
//  YarnCount+Transaction.swift
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

extension YarnCount {
    static func getYarnCount(forType: Int, searchString: String) -> YarnCount? {
        let realm = try! Realm()
        if let object = realm.objects(YarnType.self).filter("%K == %@", "entityID", forType).first {
            let count = object.yarnCounts.filter("%K == %@","count",searchString).first
            return count
        }
        return nil
    }
}

