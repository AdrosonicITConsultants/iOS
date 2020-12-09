//
//  CMS+Transaction.swift
//  CraftExchange
//
//  Created by Kalyan on 12/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension CMSCategoryACFSelf {
    
    static func getCategoryType(CategoryId: Int) -> CMSCategoryACFSelf? {
        let realm = try! Realm()
        if let object = realm.objects(CMSCategoryACFSelf.self).filter("%K == %@", "entityID", CategoryId).first {
            return object
        }
        return nil
    }
    
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CMSCategoryACFSelf.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                image = object.image
                catDescription = object.catDescription
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
}

extension CMSCategoryACFCo {
    
    static func getCategoryType(CategoryId: Int) -> CMSCategoryACFCo? {
        let realm = try! Realm()
        if let object = realm.objects(CMSCategoryACFCo.self).filter("%K == %@", "entityID", CategoryId).first {
            return object
        }
        return nil
    }
    
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CMSCategoryACFCo.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                image = object.image
                catDescription = object.catDescription
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
}

extension CMSRegionACF {
    
    static func getRegionType(ClusterId: Int) -> CMSRegionACF? {
        let realm = try! Realm()
        if let object = realm.objects(CMSRegionACF.self).filter("%K == %@", "entityID", ClusterId).first {
            return object
        }
        return nil
    }
    
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(CMSRegionACF.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                image = object.image
                regDescription = object.regDescription
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
}
