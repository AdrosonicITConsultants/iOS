//
//  User+Transaction.swift
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

extension User {
    
    static func getUser(userId: Int) -> User? {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", userId).first {
            return object
        }
        return nil
    }
    
    static func loggedIn() -> User? {
        guard let userID = KeychainManager.standard.userID else { return nil }
        let realm = try? Realm()
        return realm?.objects(User.self).filter("%K == %@", "entityID", userID).first
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.designation = designation
                object.alternateMobile = alternateMobile
                object.pancard = pancard
                object.profilePic = profilePic
                object.logo = logo
                if object.buyerCompanyDetails.count > 0 {
                    object.buyerCompanyDetails.first?.companyName = buyerCompanyDetails.first?.companyName
                    object.buyerCompanyDetails.first?.compDesc = buyerCompanyDetails.first?.compDesc
                    object.buyerCompanyDetails.first?.logo = buyerCompanyDetails.first?.logo
                    object.buyerCompanyDetails.first?.cin = buyerCompanyDetails.first?.cin
                    object.buyerCompanyDetails.first?.gstNo = buyerCompanyDetails.first?.gstNo
                    object.buyerCompanyDetails.first?.contact = buyerCompanyDetails.first?.contact
                }else {
                    object.buyerCompanyDetails = buyerCompanyDetails
                }
                
                if object.pointOfContact.count > 0 {
                    object.pointOfContact.first?.pocContantNo = pointOfContact.first?.pocContantNo
                    object.pointOfContact.first?.pocEmail = pointOfContact.first?.pocEmail
                    object.pointOfContact.first?.pocFirstName = pointOfContact.first?.pocFirstName
                    object.pointOfContact.first?.pocLastName = pointOfContact.first?.pocLastName
                }else {
                    object.pointOfContact = pointOfContact
                }
                
                object.paymentAccountList = self.paymentAccountList
                object.userProductCategories = self.userProductCategories
                object.addressList = addressList
                
                let idsToCheck = userProductCategories.compactMap { $0.entityID }
                var idsToDelete: [UserProductCategory] = []
                object.userProductCategories .forEach { (obj) in
                    if !idsToCheck.contains(obj.entityID) {
                        idsToDelete.append(obj)
                    }
                }
                realm.delete(idsToDelete)
                
                let existingIds = object.userProductCategories.compactMap { $0.entityID }
                userProductCategories .forEach { (img) in
                    if !existingIds.contains(img.entityID) {
                        object.userProductCategories.append(img)
                    }
                }
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    func saveOrUpdateUserCategory(catArr: [UserProductCategory]) {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                let idsToCheck = catArr.compactMap { $0.entityID }
                var idsToDelete: [UserProductCategory] = []
                object.userProductCategories .forEach { (obj) in
                    if !idsToCheck.contains(obj.entityID) {
                        idsToDelete.append(obj)
                    }
                }
                realm.delete(idsToDelete)
                
                let existingIds = object.userProductCategories.compactMap { $0.entityID }
                catArr .forEach { (img) in
                    if !existingIds.contains(img.entityID) {
                        object.userProductCategories.append(img)
                    }
                }
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    func saveOrUpdateProfileImage(data: Data) {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                try Disk.save(data, to: .caches, as: "\(entityID)/\(profilePic ?? "")")
                profilePicUrl = try? Disk.retrieveURL("\(entityID)/\(profilePic ?? "")", from: .caches, as: Data.self).absoluteString
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    func saveOrUpdateBrandLogo(data: Data) {
        let realm = try! Realm()
        if let object = realm.objects(User.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                try Disk.save(data, to: .caches, as: "\(entityID)/\(buyerCompanyDetails.first?.logo ?? "")")
                logoUrl = try? Disk.retrieveURL("\(entityID)/\(buyerCompanyDetails.first?.logo ?? "")", from: .caches, as: Data.self).absoluteString
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
    
    func getAllArtisansForCluster(clusterId: Int) -> [User] {
        let realm = try! Realm()
        let objects = realm.objects(User.self).filter("%K == %@", "refRoleId", "1")
        var prodCat: [User] = []
        objects.forEach { (userObj) in
            if userObj.cluster?.entityID == clusterId {
                prodCat.append(userObj)
            }
        }
        return prodCat
    }
}
