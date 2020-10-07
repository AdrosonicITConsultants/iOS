//
//  Enquiry+Transactions.swift
//  CraftExchange
//
//  Created by Preety Singh on 12/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Bond
import ReactiveKit

extension Enquiry {
    
    func searchEnquiry(searchId: Int) -> Enquiry? {
        let realm = try! Realm()
        if let object = realm.objects(Enquiry.self).filter("%K == %@", "entityID", searchId).first {
            return object
        }
        return nil
    }
    
    func updateAddonDetails(blue: Bool, name: String, moqRejected: Bool) {
        let realm = try! Realm()
        if let object = realm.objects(Enquiry.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.isMoqRejected = moqRejected
                object.isBlue = blue
                object.brandName = name
            }
        }
    }
    
    func updateArtistDetails(blue: Bool, user: Int, accDetails: [PaymentAccDetails], catIds:[Int], cluster: String) {
        let realm = try! Realm()
        if let object = realm.objects(Enquiry.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.userId = user
                object.isBlue = blue
                object.productCategories = catIds
                object.clusterName = cluster
                accDetails .forEach { (acc) in
                    if let _ = realm.objects(PaymentAccDetails.self).filter("%K == %@", "entityID", acc.entityID).first {
                    }else {
                        object.paymentAccountList.append(acc)
                    }
                }
            }
        }
    }
    
    func saveRecord() {
        let realm = try? Realm()
        if let _ = realm?.objects(Enquiry.self).filter("%K == %@", "entityID", self.entityID).first {
        }else {
            try? realm?.write {
                realm?.add(self, update: .modified)
            }
        }
    }
    
    func saveOrUpdate() {
        let realm = try! Realm()
        if let object = realm.objects(Enquiry.self).filter("%K == %@", "entityID", self.entityID).first {
            try? realm.write {
                object.alternateMobile = alternateMobile
                object.changeRequestModifiedOn = changeRequestModifiedOn
                object.changeRequestOn = changeRequestOn
                object.changeRequestStatus = changeRequestStatus
                
                object.warpYarnId = warpYarnId
                object.weftYarnId = weftYarnId
                object.extraWeftYarnId = extraWeftYarnId
                
                object.isBlue = isBlue
                object.city = city
                object.comment = comment
                object.companyName = companyName
                object.country = country
                object.eqDescription = eqDescription
                object.district = district
                object.email = email
                object.enquiryCode = enquiryCode
                object.enquiryId = enquiryId
                
                object.enquiryStageId = enquiryStageId
                object.enquiryStatusId = enquiryStatusId
                object.expectedDate = expectedDate
                object.extraWeftYarnHistoryId = extraWeftYarnHistoryId
                object.extraWeftYarnId = extraWeftYarnId
                object.firstName = firstName
 
                object.gst = gst
                object.historyProductId = historyProductId
                object.innerEnquiryStageId = innerEnquiryStageId
                object.isMoqSend = isMoqSend
                object.isPiSend = isPiSend
                object.lastName = lastName
                object.lastUpdated = lastUpdated
                object.line1 = line1
                object.line2 = line2
                object.logo = logo
                object.madeWithAnthran = madeWithAnthran
                object.madeWithAnthranHistory = madeWithAnthranHistory
                object.mobile = mobile
                
                object.orderCode = orderCode
                object.orderCreatedOn = orderCreatedOn
                object.orderReceiveDate = orderReceiveDate
                object.pincode = pincode
                
                object.pocContact = pocContact
                object.pocFirstName = pocFirstName
                object.pocLastName = pocLastName
                object.productCategoryHistoryId = productCategoryHistoryId
                object.productCategoryId = productCategoryId
                object.productCode = productCode
                
                object.productHistoryCode = productHistoryCode
                object.productHistoryImages = productHistoryImages
                object.productHistoryName = productHistoryName
                object.productId = productId
                object.productImages = productImages
                object.productName = productName
                object.productStatusHistoryId = productStatusHistoryId
                
                object.productType = productType
                object.profilePic = profilePic
                object.startedOn = startedOn
                object.state = state
                object.street = street
                object.totalAmount = totalAmount
                object.productStatusHistoryId = productStatusHistoryId
                object.productStatusId = productStatusId
                
                object.warpYarnHistoryId = warpYarnHistoryId
                object.weftYarnHistoryId = weftYarnHistoryId
            }
        } else {
            try? realm.write {
                realm.add(self, update: .modified)
            }
        }
    }
}
