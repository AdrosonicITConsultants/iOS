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
    
    func createScene(forChat: Chat?, enquiryId: Int) -> UIViewController {
        
        let controller = ChatDetailsController.init()
        
        //        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        //        let controller = storyboard.instantiateViewController(withIdentifier: "ChatDetailsController") as! ChatDetailsController
        controller.chatObj = forChat
        
        func setupRefreshActions() {
            syncData()
        }
        
        func performSync() {
            getConversation(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let dataArray = json["data"] as? [[String: Any]] {
                        for object in dataArray {
                            if let array = object["chatBoxList"] as? [[String: Any]] {
                                if let chatdata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                                    if  let chatObj = try? JSONDecoder().decode([Conversation].self, from: chatdata) {
                                        var i = 0
                                        var eqArray: [Int] = []
                                        DispatchQueue.main.async {
                                            for obj in chatObj {
                                                i+=1
                                                obj.saveOrUpdate()
                                                eqArray.append(obj.entityID)
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
        }
        
        controller.viewWillAppear = {
            syncData()
        }
        
        controller.downloadEnquiry = { (enquiryId) in
            let service = EnquiryDetailsService.init(client: self.client)
            if forChat?.enquiryOpenOrClosed == 2 {
                service.getOpenEnquiryDetails(enquiryId: enquiryId).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            service.pasrseEnquiryJson(json: json, vc: controller)
                        }
                    }
                    DispatchQueue.main.async {
                        controller.hideLoading()
                    }
                }.dispose(in: controller.bag)
            }else {
                service.getClosedEnquiryDetails(enquiryId: enquiryId).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                                   if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                                       if json["valid"] as? Bool == true {
                                           service.pasrseEnquiryJson(json: json, vc: controller)
                                       }
                                   }
                                   DispatchQueue.main.async {
                                       controller.hideLoading()
                                   }
                               }.dispose(in: controller.bag)
            }
            
        }
        
        controller.goToEnquiry = { (enquiryId) in
            if let obj = Enquiry().searchEnquiry(searchId: enquiryId ) {
                let vc = EnquiryDetailsService(client: self.client).createEnquiryDetailScene(forEnquiry: obj, enquiryId: obj.entityID) as! BuyerEnquiryDetailsController
                vc.modalPresentationStyle = .fullScreen
                if forChat?.enquiryOpenOrClosed == 2 {
                    vc.isClosed = false
                }else{
                    vc.isClosed = true
                }
                
                controller.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        controller.sendMessage = {
            self.sendMessage(enquiryId: controller.viewModel.enquiryId.value!, messageFrom: controller.viewModel.messageFrom.value!, messageTo: controller.viewModel.messageTo.value!, messageString: controller.viewModel.messageString.value!, mediaType: controller.viewModel.mediaType.value!).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            controller.messageObject = []
                            controller.viewWillAppear?()
                        }
                    }
                }
                else {
                    controller.alert("Sending message failed, please try again later")
                }
            }.dispose(in: controller.bag)
        }
        
        controller.sendMedia = {
            self.sendMedia(enquiryId: controller.viewModel.enquiryId.value!, messageFrom: controller.viewModel.messageFrom.value!, messageTo: controller.viewModel.messageTo.value!, mediaType: controller.viewModel.mediaType.value!, mediaData: controller.viewModel.mediaData.value, filename: controller.viewModel.fileName.value ?? "").bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            controller.messageObject = []
                            controller.viewWillAppear?()
                        }
                    }
                }
                else {
                    controller.alert("Sending attachment failed, please try again later")
                }
            }.dispose(in: controller.bag)
        }
        
        return controller
    }
    
    func downloadChat(vc: UIViewController, enquiryId: Int) {
        self.getSpecificChat(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { _, responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if let array = json["data"] as? [[String: Any]] {
                    if  let dataDict = array.first {
                        if let chatdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                            if let chatObj = try? JSONDecoder().decode(Chat.self, from: chatdata) {
                                DispatchQueue.main.async {
                                    
                                    if chatObj.buyerCompanyName != nil{
                                        chatObj.saveOrUpdate()
                                        if let vc1 = vc as? ChatNewListController{
                                            if let obj = Chat().searchChat(searchId: enquiryId) {
                                            let vc2 = self.createScene(forChat: obj, enquiryId: enquiryId)
                                            vc2.modalPresentationStyle = .fullScreen
                                            vc1.navigationController?.pushViewController(vc2, animated: true)
                                            let viewControllers = vc2.navigationController!.viewControllers
                                           vc2.navigationController!.viewControllers.remove(at: viewControllers.count - 2)
                                            }
                                        }

                                        else {
                                            
                                            if let obj = Chat().searchChat(searchId: enquiryId) {
                                               
                                                let vc1 = self.createScene(forChat: obj, enquiryId: enquiryId)
                                                vc1.modalPresentationStyle = .fullScreen
                                                vc.navigationController?.pushViewController(vc1, animated: true)
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
    }
}



