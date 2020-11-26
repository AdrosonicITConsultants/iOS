//
//  ChatDetailsService.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class ChatDetailsService: BaseService<Data> {

    required init() {
        super.init()
    }
    
     func getConversation(enquiryId: Int) -> SafeSignal<Data> {
        return Conversation.getConversation(enquiryId: enquiryId).response(using: client).debug()
     }
    
    func getAdminChatEscalations(enquiryId: Int) -> SafeSignal<Data> {
       return Conversation.getAdminChatEscalations(enquiryId: enquiryId).response(using: client).debug()
    }
}
