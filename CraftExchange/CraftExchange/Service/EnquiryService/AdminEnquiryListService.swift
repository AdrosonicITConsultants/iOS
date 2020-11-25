//
//  AdminEnquiryListService.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminEnquiryListService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchEnquiries(parameter:[String: Any]) -> SafeSignal<Data> {
        return AdminEnquiry.getAdminEnquiries(parameters: parameter).response(using: client).debug()
    }
    
    func fetchIncompleteClosedEnquiries(parameter:[String: Any]) -> SafeSignal<Data> {
        return AdminEnquiry.getAdminIncompleteClosedEnquiries(parameters: parameter).response(using: client).debug()
    }
    
    func fetchUserDetailsForEnquiry(enquiryId: Int) -> SafeSignal<Data> {
        return AdminEnquiry.getUserDetailsForEnquiry(enquiryId: enquiryId).response(using: client).debug()
    }
}
