//
//  BuyerNotificationScene.swift
//  CraftExchange
//
//  Created by Ashar on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension AdminNotificationService {
    func createScene() -> UIViewController {
        let roleId = KeychainManager.standard.userRoleId!
        
        let storyboard = UIStoryboard(name: "AdminNotification", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminNotificationController") as! AdminNotificationController
       
        func performSync(){
            getAllTheNotifications().bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let dataDict = json["data"] as? Dictionary<String,Any> {
                            guard let notiObj = dataDict["getAllNotifications"] as? [[String: Any]] else {
                                return
                            }
                            if let notidata = try? JSONSerialization.data(withJSONObject: notiObj, options: .fragmentsAllowed) {
                                if  let notiAdmin = try? JSONDecoder().decode([AdminNotifications].self, from: notidata) {
                                    DispatchQueue.main.async {
                                       notiAdmin.forEach { (obj) in
                                            obj.saveOrUpdate()
                                            controller.allNotificationIds.append(obj.notificationId)
                                       }
                                       controller.endRefresh()
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
                
        
        func syncData() {
            performSync()
        }

        controller.viewWillAppear = {
            syncData()
        }
        
        return controller
    }
}
