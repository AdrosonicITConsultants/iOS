//
//  EnquiryListService.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class EnquiryListService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getEnquiryStages() -> SafeSignal<Data> {
      return Enquiry.getEnquiryStages().response(using: client).debug()
    }
    
    func getOngoingEnquiries() -> SafeSignal<Data> {
      return Enquiry.getOpenEnquiries().response(using: client).debug()
    }
    
    func getClosedEnquiries() -> SafeSignal<Data> {
      return Enquiry.getClosedEnquiries().response(using: client).debug()
    }
}
