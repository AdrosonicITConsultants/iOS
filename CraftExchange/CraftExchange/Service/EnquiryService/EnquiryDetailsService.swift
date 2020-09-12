//
//  EnquiryDetailsService.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class EnquiryDetailsService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getOpenEnquiryDetails(enquiryId: Int) -> SafeSignal<Data> {
      return Enquiry.getOpenEnquiryDetails(enquiryId: enquiryId).response(using: client).debug()
    }
}
