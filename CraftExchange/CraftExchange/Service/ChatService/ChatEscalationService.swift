//
//  ChatEscalationService.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 09/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class ChatEscalationService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    
    func getEscalations() -> SafeSignal<Data> {
        return Chat.getEscalations().response(using: client).debug()
    }
    
    func getEscalationSummary(enquiryId: Int) -> SafeSignal<Data> {
        return Chat.getEscalationsSummary(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func sendMessage(enquiryId: Int, messageFrom: Int, messageTo: Int, messageString: String, mediaType: Int)  -> SafeSignal<Data> {
        return Chat.sendMessage(enquiryId: enquiryId, messageFrom: messageFrom, messageTo: messageTo, messageString: messageString, mediaType: mediaType).response(using: client).debug()
    }
    
    func raiseEscalation(enquiryId: Int, catId: Int, escalationFrom: Int, escalationTo: Int, message: String) -> SafeSignal<Data> {
        return Chat.raiseEscalation(enquiryId: enquiryId, catId: catId, escalationFrom: escalationFrom, escalationTo: escalationTo, message: message).response(using: client).debug()
    }
    
    func resolveEscalation(enquiryId: Int) -> SafeSignal<Data> {
        return Chat.resolveEscalation(enquiryId: enquiryId).response(using: client).debug()
    }
}
