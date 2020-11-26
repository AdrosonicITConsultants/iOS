//
//  ChatListScene.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension ChatListService {
    func createScene() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatListController") as! ChatListController
        
        func setupRefreshActions() {
            syncData()
        }
        
        func performSync() {
            getChatList().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    parseEnquiry(json: json, isOngoing: true)
                }else {
                   controller.endRefresh()
                }
            }.dispose(in: controller.bag)
           
            controller.hideLoading()
        }
        
        func parseEnquiry(json: [String: Any], isOngoing: Bool) {
            if let array = json["data"] as? [[String: Any]] {
                var i = 0
                var esclation = 0
                var eqArray: [Int] = []
                
                array.forEach { (dataDict) in
                    i+=1
                    if let chatdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                        if let chatObj = try? JSONDecoder().decode(Chat.self, from: chatdata) {
                            DispatchQueue.main.async {
                                print("chatObj: \(chatObj)")
                                esclation += chatObj.escalation
                                if chatObj.buyerCompanyName != nil{
                                    chatObj.saveOrUpdate()
                                    chatObj.updateAddonDetails(isOld: isOngoing)
                                    eqArray.append(chatObj.entityID)
                                    if i == array.count {
                                        if isOngoing {
                                            controller.chatList = eqArray
                                            
                                            if esclation == 1{
                                                controller.escalationsButton.setTitle(" \(esclation) Escalation", for: .normal)
                                            }else {
                                                controller.escalationsButton.setTitle(" \(esclation) Escalations", for: .normal)
                                            }
                                            
                                        }
                                        controller.endRefresh()
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
        }
        
        func syncData() {
            guard !controller.isEditing else { return }
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
                return
            }
            performSync()
        }
        controller.markasRead = {  (id) in
            self.markAsRead(enquiryId: id).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    DispatchQueue.main.async {
                        controller.viewWillAppear?()
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        controller.viewWillAppear = {
            syncData()
        }
        
        return controller
    }
    
    func createNewScene() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatNewListController") as! ChatNewListController
        
        func setupRefreshActions() {
            syncData()
        }
        
        func performSync() {
            getNewChatList().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    parseEnquiry(json: json, isOngoing: false)
                }
            }.dispose(in: controller.bag)
            controller.hideLoading()
        }
        
        func parseEnquiry(json: [String: Any], isOngoing: Bool) {
            if let array = json["data"] as? [[String: Any]] {
                if array.count != 0 {
                var i = 0
                var eqArray: [Int] = []
                array.forEach { (dataDict) in
                    i+=1
                    if let chatdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                        if let chatObj = try? JSONDecoder().decode(Chat.self, from: chatdata) {
                            DispatchQueue.main.async {
                                print("chatObj: \(chatObj)")
                                
                                if chatObj.buyerCompanyName != nil{
                                    chatObj.saveOrUpdate()
                                    chatObj.updateAddonDetails(isOld: isOngoing)
                                    eqArray.append(chatObj.entityID)
                                    if i == array.count {
                                        if !isOngoing {
                                            controller.newChatList = eqArray
                                        }
                                        controller.endRefresh()
                                    }
                                }
                            }
                        }
                    }
                    
                }
                }else{
                     controller.endRefresh()
                }
            }
        }
        
        func syncData() {
            guard !controller.isEditing else { return }
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
                return
            }
            performSync()
        }
        
        controller.viewWillAppear = {
            syncData()
        }
        
        
        
        controller.initiateChat = { (enquiryId) in
            let service = ChatListService.init(client: self.client)
            service.initiateConversation(vc: controller, enquiryId: enquiryId)
            
        }
        
        return controller
    }
    
    func initiateConversation(vc: UIViewController, enquiryId: Int){
        self.initiateChat(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
            DispatchQueue.main.async {
                do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                
                    let service = ChatDetailsService.init(client: client)
                    service.downloadChat(vc: vc, enquiryId: enquiryId)
                
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}





