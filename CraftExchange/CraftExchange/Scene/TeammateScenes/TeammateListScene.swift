//
//  TeammateListScene.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 18/11/20.
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
    func createScene() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchTeammateController") as! SearchTeammateController
        
        func performSync(page: Int) {
            fetchAdminTeam(pageNo: page).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    parseAdminTeam(json: json, isOngoing: true)
                }else {
                   controller.endRefresh()
                }
            }.dispose(in: controller.bag)
            controller.hideLoading()
        }
        
        func parseAdminTeam(json: [String: Any], isOngoing: Bool) {
            if let array = json["data"] as? [[String: Any]] {
                if array.count == 0 {
                    controller.reachedSearchLimit = true
                } else {
                    var i = 0
                    array.forEach { (dataDict) in
                        i+=1
                        if let teamdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                            if let teamObj = try? JSONDecoder().decode(AdminTeammate.self, from: teamdata) {
                                teamObj.saveOrUpdate()
                                controller.idList.append(teamObj.id)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        controller.endRefresh()
                        if controller.reachedSearchLimit == false {
                            controller.loadPage += 1
                            performSync(page: controller.loadPage)
                        }
                    }
                }
            }
            else {
                controller.reachedSearchLimit = true
            }
        }
        
        controller.refreshSearchResult = { (loadPage) in
            performSync(page: loadPage)
        }
        
        func syncData() {
            guard !controller.isEditing else { return }
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
                return
            }
            performSync(page: 1)
        }
        
        controller.viewWillAppear = {
            syncData()
            getAdminRoles()
        }
        
        func getAdminRoles(){
            self.fetchAdminRoles().bind(to: controller, context: .global(qos: .background)) { _, responseData in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if let dataArray = json["data"] as? [[String: Any]] {
                                if let chatdata = try? JSONSerialization.data(withJSONObject: dataArray, options: .fragmentsAllowed) {
                                if  let chatObj = try? JSONDecoder().decode([AdminRoles].self, from: chatdata) {
                                    var i = 0
                                    var eqArray: [Int] = []
                                    DispatchQueue.main.async {
                                        for obj in chatObj {
                                            i+=1
                                            obj.saveOrUpdate()
                                            eqArray.append(obj.id)
                                        }
                                        if i == chatObj.count {
                                            controller.adminRoleId = eqArray
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.dispose(in: controller.bag)
        }
                
        return controller
    }
    
}
