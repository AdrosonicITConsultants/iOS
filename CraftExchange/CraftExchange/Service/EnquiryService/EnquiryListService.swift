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
    
    func getAvailableProductEnquiryStages() -> SafeSignal<Data> {
      return Enquiry.getAvailableProductEnquiryStages().response(using: client).debug()
    }
    
    func getEnquiryInnerStages() -> SafeSignal<Data> {
      return Enquiry.getEnquiryInnerStages().response(using: client).debug()
    }
    
    func getMOQDeliveryTimes() -> SafeSignal<Data>  {
        return Enquiry.getMOQDeliveryTimes().response(using: client).debug()
    }
    
    func getCurrencySigns() -> SafeSignal<Data>  {
        return Enquiry.getCurrencySigns().response(using: client).debug()
    }
    
    func getOngoingEnquiries() -> SafeSignal<Data> {
      return Enquiry.getOpenEnquiries().response(using: client).debug()
    }
    
    func getClosedEnquiries() -> SafeSignal<Data> {
      return Enquiry.getClosedEnquiries().response(using: client).debug()
    }
    
}
