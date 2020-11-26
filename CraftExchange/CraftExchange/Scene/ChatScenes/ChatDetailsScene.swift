//
//  ChatDetailsScene.swift
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

extension ChatDetailsService {
    
    func createScene(enquiryId: Int) -> UIViewController {
        
        let controller = ChatDetailsController.init()
        
        //        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        //        let controller = storyboard.instantiateViewController(withIdentifier: "ChatDetailsController") as! ChatDetailsController
        // controller.chatObj = forChat
        controller.enquiryId = enquiryId
        
        func setupRefreshActions() {
            syncData()
        }
        
        func performSync() {
            controller.messageObject = []
            getConversation(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let dataArray = json["data"] as? [[String: Any]] {
                        for object in dataArray {
                            if let array = object["adminChatResponses"] as? [[String: Any]] {
                                var i = 0
                                for object2 in array{
                                    i+=1
                                    if let chatDataObj = object2["chat"] as? [String: Any] {
                                        if let isBuyer = object2["isBuyer"] as? Int {
                                            if let chatdata = try? JSONSerialization.data(withJSONObject: chatDataObj, options: .fragmentsAllowed) {
                                                if  let chatObj = try? JSONDecoder().decode(Conversation.self, from: chatdata) {
                                                    
                                                    var eqArray: [Int] = []
                                                    DispatchQueue.main.async {
                                                        
                                                        controller.messages = []
                                                        //  for obj in chatObj {
                                                        
                                                        chatObj.saveOrUpdate()
                                                        chatObj.updateAddonDetails(isBuyer: isBuyer)
                                                        eqArray.append(chatObj.entityID)
                                                        print("\(chatObj)")
                                                        //  }
                                                        if i == array.count {
                                                            controller.id = eqArray
                                                            
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
                    }
                    
                }
            }.dispose(in: controller.bag)
            
            controller.hideLoading()
        }
        
        func syncData() {
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.messageObject = []
                    controller.endRefresh()
                }
                return
            }
            performSync()
        }
        
        controller.viewWillAppear = {
            syncData()
        }
        return controller
        
    }
}



