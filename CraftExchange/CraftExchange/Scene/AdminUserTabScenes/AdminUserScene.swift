//
//  AdminUserScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension AdminUserService {
    func createScene() -> UIViewController {

        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminUserController") as! AdminUserController
        
        controller.loadMetaData = {
            let service = AdminHomeScreenService.init(client: self.client)
            service.fetchClusterData(vc: controller)
        }
        
        controller.viewWillAppear = {
            getUsersCount()
            setupRefreshActions()
        }
        
        func setupRefreshActions() {
            self.getAllUsers(clusterId: controller.selectedCluster?.entityID ?? -1, pageNo: controller.pageNo, rating: Int(controller.selectedRating), roleId: controller.segmentedControl.selectedSegmentIndex == 0 ? 1 : 2, searchStr: "", sortBy: "", sortType: "").bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        if array.count == 0 {
                            DispatchQueue.main.async {
                                controller.reachedLimit = true
                                refreshUserList()
                            }
                        }else {
                            var i = 0
                            array .forEach { (obj) in
                                i+=1
                                if let userdata = try? JSONSerialization.data(withJSONObject: obj, options: .fragmentsAllowed) {
                                    if let user = try? JSONDecoder().decode(AdminUser.self, from: userdata) {
                                        DispatchQueue.main.async {
                                            user.saveOrUpdate()
                                            if i == array.count {
                                                refreshUserList()
                                            }
                                        }
                                    }else {
                                        print("User Obj not saved: \(obj)")
                                    }
                                }
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        func refreshUserList() {
            let realm = try? Realm()
            if controller.segmentedControl.selectedSegmentIndex == 0 {
                controller.allUsers = realm?.objects(AdminUser.self).filter("%K != nil","weaverId")
                if let cluster = controller.selectedCluster?.clusterDescription {
                    controller.allUsers = controller.allUsers?.filter("%K == %@", "cluster",cluster)
                }
                if controller.selectedRating != -1 {
                    controller.allUsers = controller.allUsers?.filter("%K >= %@","rating",controller.selectedRating)
                }
            }else {
                controller.allUsers = realm?.objects(AdminUser.self).filter("%K == nil","weaverId")
                if controller.selectedRating != -1 {
                    controller.allUsers = controller.allUsers?.filter("%K >= %@","rating",controller.selectedRating)
                }
            }
            if let searchtext = controller.AdminDbSearch.searchTextField.text, searchtext != "" {
                let predicate = NSPredicate.init(format: "%K contains[cd] %@ OR %K contains[cd] %@ OR %K contains[cd] %@ OR %K contains[cd] %@","email",searchtext,"firstName",searchtext,"brandName",searchtext,"mobile",searchtext)
                controller.allUsers = controller.allUsers?.filter(predicate)
            }
            controller.sortTable()
            if controller.reachedLimit == false {
                controller.pageNo += 1
                setupRefreshActions()
            }
        }
        
        func getUsersCount(){
            self.getAllUsersCount(clusterId: -1, pageNo: 1, rating: -1, roleId: controller.segmentedControl.selectedSegmentIndex == 0 ? 1 : 2, searchStr: "", sortBy: "", sortType: "").bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let count = json["data"] as? Int {
                        DispatchQueue.main.async {
                            controller.totalCount = count
                            if controller.segmentedControl.selectedSegmentIndex == 0 {
                                controller.CountLabel.text = "Total Artisans: \(count)"
                            }else {
                                controller.CountLabel.text = "Total Buyers: \(count)"
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        return controller
    }
}
