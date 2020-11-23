//
//  TeammateDetailScene.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension MarketingTeammateService {
    
    func createSceneTeammateDetail(forTeammate: AdminTeammate?, id: Int) -> UIViewController {
                
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchedTeammateInfoController") as! SearchedTeammateInfoController
        
        func performSync() {
            fetchAdminProfile(userId: id).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let dataArray = json["data"] as? [[String: Any]] {
                            if let chatdata = try? JSONSerialization.data(withJSONObject: dataArray, options: .fragmentsAllowed) {
                                if  let chatObj = try? JSONDecoder().decode([AdminTeamUserProfile].self, from: chatdata) {
                                    DispatchQueue.main.async {
                                        for chat in chatObj {
                                            controller.textValues = chat
                                            controller.userLabel.text = chat.username
                                            controller.adminPositionLabel.text = chat.role
                                            controller.EmailValue.text = chat.email
                                            controller.MemberSinceValue.text = (Date().ttceFormatter(isoDate: chat.memberSince ?? ""))
                                            controller.MobNoValue.text = chat.mobile
//                                            if chat.status == 1 {
//                                                controller.StatusLabel.text = "Active"
//                                            }
//                                            controller.s
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    controller.hideLoading()
                }
            }.dispose(in: controller.bag)
        }
        
        controller.viewWillAppear = {
            performSync()
        }
        
        return controller
    }
}


