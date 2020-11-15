//
//  BuyerNotificationScene.swift
//  CraftExchange
//
//  Created by Kalyan on 02/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension NotificationService {
    func createScene() -> UIViewController {
        let roleId = KeychainManager.standard.userRoleId!
        var storyboard: UIStoryboard
        var controller: NotificationController
        
        if roleId == 1{
            storyboard = UIStoryboard(name: "ArtisanTabbar", bundle: nil)
            controller = storyboard.instantiateViewController(withIdentifier: "ArtisanNotificationController") as! NotificationController
        }else {
            storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
            controller = storyboard.instantiateViewController(withIdentifier: "BuyerNotificationController") as! NotificationController
        }
       
        func performSync()   {
            getAllTheNotifications().toLoadingSignal().consumeLoadingState(by: controller)
                .bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                        if let dataDict = json["data"] as? Dictionary<String,Any>
                        {
                            guard let notiObj = dataDict["getAllNotifications"] as? [[String: Any]] else {
                                return
                            }
                            if let notidata = try? JSONSerialization.data(withJSONObject: notiObj, options: .fragmentsAllowed) {
                                if  let notiBuyer = try? JSONDecoder().decode([Notifications].self, from: notidata) {
                                    DispatchQueue.main.async {
                                        notiBuyer.forEach { (obj) in
                                            obj.saveOrUpdate()
                                        }
                                        controller.endRefresh()
                                    }
                                }
                            }
                        }
                    }
            }.dispose(in: controller.bag)
            controller.hideLoading()
        }
        
        controller.markasRead = { (notificationId, index) in
            let request = OfflineNotificationRequest(type: .markAsReadNotification, notificationId: notificationId )
            OfflineRequestManager.defaultManager.queueRequest(request)
            DispatchQueue.main.async {
                controller.allNotifications?.remove(at: index)
                controller.tableView.reloadData()
                controller.notificationCount = controller.allNotifications?.count ?? 0
                let count =  controller.notificationCount
                if count == 0 {
                    controller.notificationsLabel?.text = "No new notifications"
                }
                else {
                    controller.notificationsLabel?.text = "\(count) new notifications"
                }
            }
            
        }
        
        
        func removeNotifications(){
            let request = OfflineNotificationRequest(type: .markAsAllReadNotification, notificationId: 0)
            OfflineRequestManager.defaultManager.queueRequest(request)
            DispatchQueue.main.async {
                controller.allNotifications?.removeAll()
                controller.tableView.reloadData()
                controller.notificationCount -= 0
                controller.notificationsLabel?.text = "No new notifications"
            }
            
        }
        
        func syncData() {
            performSync()
            
        }
        controller.viewWillAppear = {
            syncData()
            
        }
        controller.markAsReadAllActions = {
            removeNotifications()
        }
        return controller
    }
}
