//
//  AdminChatEscalationScene.swift
//  CraftExchange
//
//  Created by Kalyan on 26/11/20.
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
    
    func createEscalationScene(enquiryId: Int) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "AdminEnquiryTab", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminChatEscalationController") as! AdminChatEscalationController
        
        func setupRefreshActions() {
            syncData()
        }
        
        func performSync() {
            controller.showLoading()
            getAdminChatEscalations(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let dataArray = json["data"] as? [[String: Any]] {
                        if let chatdata = try? JSONSerialization.data(withJSONObject: dataArray, options: .fragmentsAllowed) {
                            if  let allEscalations = try? JSONDecoder().decode([AdminChatEscalationObject].self, from: chatdata) {
                                DispatchQueue.main.async {
                                    
                                    controller.allEscalations = allEscalations
                                    controller.endRefresh()
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
