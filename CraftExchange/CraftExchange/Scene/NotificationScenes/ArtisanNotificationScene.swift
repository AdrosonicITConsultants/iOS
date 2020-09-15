//
//  ArtisanNotificationScene.swift
//  CraftExchange
//
//  Created by Kalyan on 11/09/20.
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
    func createArtisanScene() -> UIViewController {
        let storyboard = UIStoryboard(name: "ArtisanTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ArtisanNotificationController") as! NotificationController
        
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
                                        controller.allNotifications = notiBuyer
                                        let count = dataDict["count"]! as! Int
                                        if count == 0 {
                                            controller.notificationsLabel?.text = "No new notifications"
                                        }
                                        else {
                                            controller.notificationsLabel?.text = "\(count) new notifications"
                                        }
                                        
                                        controller.tableView.reloadData()
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
            }.dispose(in: controller.bag)
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
            //            self.markAsReadNotification(notificationId: notificationId).bind(to: controller, context: .global(qos: .background)) {_,responseData in
            //                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
            //                    if json["valid"] as? Bool == true {
            //                        DispatchQueue.main.async {
            //                            controller.viewDidLoad()
            //                        }
            //                    }
            //                }
            //            }.dispose(in: controller.bag)
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
            //            self.markAsAllRead().bind(to: controller, context: .global(qos: .background)) {_,responseData in
            //                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
            //                    if json["valid"] as? Bool == true {
            //                        DispatchQueue.main.async {
            //
            //                            controller.viewDidLoad()
            //                        }
            //                    }
            //                }
            //            }.dispose(in: controller.bag)
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
