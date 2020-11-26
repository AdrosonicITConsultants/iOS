//
//  ChatEscalationScene.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 09/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension ChatEscalationService {

    func createScene(forChat: Chat?, enquiryId: Int) -> UIViewController {

        let controller = ChatEscalationController.init()

        //        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        //        let controller = storyboard.instantiateViewController(withIdentifier: "ChatDetailsController") as! ChatDetailsController
        controller.chatObj = forChat

        func setupRefreshActions() {
            syncData()
        }
        
        func performSync() {
            getEscalationSummary(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if let dataArray = json["data"] as? [[String: Any]] {
                                if let chatdata = try? JSONSerialization.data(withJSONObject: dataArray, options: .fragmentsAllowed) {
                                if  let chatObj = try? JSONDecoder().decode([EscalationConversation].self, from: chatdata) {
                                    var i = 0
                                    var eqArray: [Int] = []
                                    DispatchQueue.main.async {
                                        controller.messages = []
                                        for obj in chatObj {
                                            i+=1
                                            obj.saveOrUpdate()
                                            eqArray.append(obj.enquiryId)
                                            print("\(obj)")
                                        }
                                        if i == chatObj.count {
                                            controller.id = eqArray
                                        }
                                    controller.endRefresh()
                                }
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }

      
        func syncData() {
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
                return
            }
            performSync()
            getEscalationsAll()
        }
        
        controller.viewWillAppear = {
            syncData()
        }
    
        func getEscalationsAll(){
            getEscalations().bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let dataArray = json["data"] as? [[String: Any]] {
                            if let chatdata = try? JSONSerialization.data(withJSONObject: dataArray, options: .fragmentsAllowed) {
                            if  let chatObj = try? JSONDecoder().decode([EscalationCategory].self, from: chatdata) {
                                var i = 0
                                var eqArray: [Int] = []
                                DispatchQueue.main.async {
                                    for obj in chatObj {
                                        i+=1
                                        obj.saveOrUpdate()
                                        eqArray.append(obj.id)
                                        print("\(obj)")
                                    }
                                    if i == chatObj.count {
                                        controller.catId = eqArray
                                    }
                                }
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        controller.sendEscalationMessage = { (enquiryId, catId, escalationFrom, escalationTo, message) in
            controller.showLoading()
            self.raiseEscalation(enquiryId: enquiryId, catId: catId, escalationFrom: escalationFrom, escalationTo: escalationTo, message: message).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            controller.messageObject = []
                            controller.viewWillAppear?()
                            controller.hideLoading()
                        }
                    }
                }
                else {
                    controller.hideLoading()
                    controller.alert("Sending message failed, please try again later")
                }
            }.dispose(in: controller.bag)
        }
        
        controller.resolveEscalation = { (escalationId) in
            controller.showLoading()
            self.resolveEscalation(enquiryId: escalationId).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            DispatchQueue.main.async {
                                controller.messageObject = []
                                controller.viewWillAppear?()
                                controller.hideLoading()
                            }
                        }
                    }
                    else {
                        controller.alert("Sending message failed, please try again later")
                        controller.hideLoading()
                    }
            }.dispose(in: controller.bag)
        }
        
        return controller
    }

}

