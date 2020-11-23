//
//  AdminUserProfileScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/11/20.
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

    func createBuyerProfileScene(forUser:Int) -> UIViewController {

        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminBuyerUserDetailController") as! AdminBuyerUserDetailController
        controller.viewModel.viewWillAppear = {
            self.loadUser(userId: forUser, vc: controller)
        }
        controller.viewModel.refreshProfile = {
            let realm = try? Realm()
            controller.userObject = realm?.objects(User.self).filter("%K == %@","entityID",forUser).first
        }
        controller.viewModel.updateRating = { (value) in
            self.changeRating(forUser: forUser, value: value, controller: controller)
        }
        controller.viewModel.updateProfileActiveStatus = {
            controller.showLoading()
            self.changeUserStatus(forUser: forUser, userObject: controller.userObject, controller: controller)
        }
        return controller
    }
    
    func createArtisanProfileScene(forUser:Int) -> UIViewController {

        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminUserDetailController") as! AdminUserDetailController
        controller.viewModel.viewDidLoad = {
            self.loadUser(userId: forUser, vc: controller)
        }
        controller.viewModel.refreshProfile = {
            let realm = try? Realm()
            controller.userObject = realm?.objects(User.self).filter("%K == %@","entityID",forUser).first
        }
        controller.viewModel.updateRating = { (value) in
            self.changeRating(forUser: forUser, value: value, controller: controller)
        }
        controller.viewModel.updateProfileActiveStatus = {
            controller.showLoading()
            self.changeUserStatus(forUser: forUser, userObject: controller.userObject, controller: controller)
        }
        return controller
    }
    
    func changeUserStatus(forUser: Int, userObject: User?, controller: UIViewController) {
        if userObject?.status == 1 {
            //Deactivate User
            self.deActivateUser(userId: forUser).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let isValid = json["valid"] as? Bool, isValid == true {
                        DispatchQueue.main.async {
                            controller.hideLoading()
                            userObject?.saveOrUpdateProfileStatus(newStatus: 2)
                            controller.alert("Success", "\(json["data"] as? String ?? "User Deactivated")", callback: nil)
                            if let rightButtonItem = controller.navigationItem.rightBarButtonItem {
                                rightButtonItem.image = UIImage.init(systemName: "person.crop.circle.badge.xmark")
                                rightButtonItem.tintColor = .systemRed
                            }
                        }
                    }
                }
            }
        }else {
            //Activate User
            self.activateUser(userId: forUser).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let isValid = json["valid"] as? Bool, isValid == true {
                        DispatchQueue.main.async {
                            controller.hideLoading()
                            userObject?.saveOrUpdateProfileStatus(newStatus: 1)
                            controller.alert("Success", "\(json["data"] as? String ?? "User Activated")", callback: nil)
                            if let rightButtonItem = controller.navigationItem.rightBarButtonItem {
                                rightButtonItem.image = UIImage.init(systemName: "person.crop.circle.badge.checkmark")
                                rightButtonItem.tintColor = UIColor().CEGreen()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func changeRating(forUser: Int, value: Float, controller: UIViewController) {
        self.updateUserRating(userId: forUser, rating: value).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                if let isValid = json["valid"] as? Bool, isValid == true {
                    DispatchQueue.main.async {
                        controller.alert("Success", "\(json["data"] as? String ?? "Rating updated")", callback: nil)
                    }
                }
            }
        }
    }
    
    func loadUser(userId: Int, vc: UIViewController) {
        self.fetchUserProfile(userId: userId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                if let dataDict = json["data"] as? Dictionary<String,Any> {
                    if let userData = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                        if  let object = try? JSONDecoder().decode(User.self, from: userData) {
                            DispatchQueue.main.async {
                                object.saveOrUpdate()
                                NotificationCenter.default.post(name: NSNotification.Name.init("UserProfileReceived"), object: nil)
                            }
                        }
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
}
