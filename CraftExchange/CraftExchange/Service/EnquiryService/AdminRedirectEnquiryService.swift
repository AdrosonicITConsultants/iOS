//
//  AdminRedirectEnquiryService.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminRedirectEnquiryService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchCustomRedirectEnquiries(pageNo: Int, sortBy: String, sortType: String ) -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getCustomRedirectEnquiries(pageNo: pageNo, sortBy: sortBy, sortType: sortType).response(using: client).debug()
    }
    func fetchCustomRedirectEnquiriesCount() -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getCustomRedirectEnquiriesCount().response(using: client).debug()
    }
    
    func fetchFaultyRedirectEnquiries(pageNo: Int, sortBy: String, sortType: String ) -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getFaultyRedirectEnquiries(pageNo: pageNo, sortBy: sortBy, sortType: sortType).response(using: client).debug()
    }
    func fetchFaultyRedirectEnquiriesCount() -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getFaultyRedirectEnquiriesCount().response(using: client).debug()
    }
    
    func fetchOtherRedirectEnquiries(pageNo: Int, sortBy: String, sortType: String ) -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getOtherRedirectEnquiries(pageNo: pageNo, sortBy: sortBy, sortType: sortType).response(using: client).debug()
    }
    func fetchOtherRedirectEnquiriesCount() -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getOtherRedirectEnquiriesCount().response(using: client).debug()
    }
    
    func fetchLessThanEightRatingArtisans(clusterId: Int, searchString: String?, enquiryId: Int ) -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getLessThanEightRatingArtisans(clusterId: clusterId, searchString: searchString, enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getAllArtisansRedirect(clusterId: Int, enquiryId: Int, searchString: String) -> SafeSignal<Data> {
        return AdminRedirectEnquiry.getAllArtisansRedirect(clusterId: clusterId, enquiryId: enquiryId, searchString: searchString).response(using: client).debug()
    }
    
    func sendCustomEnquiry(enquiryId: Int, userIds: String) -> SafeSignal<Data> {
        return AdminRedirectEnquiry.sendCustomEnquiry(enquiryId: enquiryId, userIds: userIds).response(using: client).debug()
    }
    
}

