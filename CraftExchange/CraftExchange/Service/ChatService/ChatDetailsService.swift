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
        return Chat.getConversation(enquiryId: enquiryId).response(using: client).debug()
     }
    
    func sendMessage(enquiryId: Int, messageFrom: Int, messageTo: Int, messageString: String, mediaType: Int)  -> SafeSignal<Data> {
        return Chat.sendMessage(enquiryId: enquiryId, messageFrom: messageFrom, messageTo: messageTo, messageString: messageString, mediaType: mediaType).response(using: client).debug()
    }
    
    func sendMedia(enquiryId: Int, messageFrom: Int, messageTo: Int, mediaType: Int,  mediaData: Data?, filename: String?) -> SafeSignal<Data> {
           return Chat.sendMedia(enquiryId: enquiryId, messageFrom: messageFrom, messageTo: messageTo, mediaType: mediaType, mediaData: mediaData, filename: filename).response(using: client).debug()
    }
}
