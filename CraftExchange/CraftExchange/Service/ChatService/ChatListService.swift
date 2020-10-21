//
//  ChatListService.swift
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

class ChatListService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getChatList() -> SafeSignal<Data> {
      return Chat.getChatList().response(using: client).debug()
    }
    
    func getNewChatList() -> SafeSignal<Data> {
      return Chat.getNewChatList().response(using: client).debug()
    }
    
    func initiateChat(enquiryId: Int)-> SafeSignal<Data> {
        return Chat.initiateChat(enquiryId: enquiryId).response(using: client).debug()
    }
    func markAsRead(enquiryId: Int) -> SafeSignal<Data> {
       return Chat.getConversation(enquiryId: enquiryId).response(using: client).debug()
    }
}
