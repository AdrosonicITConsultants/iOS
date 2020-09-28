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
    
    func closeEnquiry(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.closeEnquiry(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func savePI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int,  ppu: Int, quantity: Int,sgst: Int)-> SafeSignal<Data>  {
        
        return Enquiry.savePI(enquiryId: enquiryId, cgst: cgst, expectedDateOfDelivery: expectedDateOfDelivery, hsn: hsn,  ppu: ppu, quantity: quantity,sgst: sgst).response(using: client).debug()
        
    }
    func sendPI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int,  ppu: Int, quantity: Int,sgst: Int)-> SafeSignal<Data>  {
        
        return Enquiry.sendPI(enquiryId: enquiryId, cgst: cgst, expectedDateOfDelivery: expectedDateOfDelivery, hsn: hsn,  ppu: ppu, quantity: quantity,sgst: sgst).response(using: client).debug()
        
    }
}
