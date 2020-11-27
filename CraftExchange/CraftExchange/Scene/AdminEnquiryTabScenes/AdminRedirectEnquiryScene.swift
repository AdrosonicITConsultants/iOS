//
//  AdminRedirectEnquiryScene.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension AdminRedirectEnquiryService {
    func createScene() -> UIViewController {
    let storyboard = UIStoryboard(name: "AdminEnquiryTab", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "AdminRedirectEnquiryController") as! AdminRedirectEnquiryController
        
        vc.viewWillAppear0 = { (sortType) in
            self.fetchCustomRedirectEnquiries(pageNo: vc.pageNo, sortBy: "date", sortType: sortType).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        if let enquirydata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                            if array.count == 0 {
                                DispatchQueue.main.async {
                                    vc.reachedLimit = true
                                    vc.endRefresh()
                                }
                            }else{
                                if let object = try? JSONDecoder().decode([AdminRedirectEnquiry].self, from: enquirydata) {
                                DispatchQueue.main.async {
                                    vc.allRedirectEnquiries = (vc.allRedirectEnquiries ?? []) + object
                                    vc.endRefresh()
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }.dispose(in: vc.bag)
            
            self.fetchCustomRedirectEnquiriesCount().bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                    if let data = json["data"] as? Int {
                        DispatchQueue.main.async {
                        print(data)
                            vc.redirectEnquiriesCount.text = "\(data )"
                        }
                    }
                }
                }else{
                    vc.redirectEnquiriesCount.text = "0"
                }
            }.dispose(in: vc.bag)
        }
        
        vc.viewWillAppear1 = { (sortType) in
            self.fetchFaultyRedirectEnquiries(pageNo: vc.pageNo, sortBy: "date", sortType: sortType).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        if let enquirydata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                            if array.count == 0 {
                                DispatchQueue.main.async {
                                    vc.reachedLimit = true
                                    vc.endRefresh()
                                }
                            }else{
                                if let object = try? JSONDecoder().decode([AdminRedirectEnquiry].self, from: enquirydata) {
                                DispatchQueue.main.async {
                                    vc.allRedirectEnquiries = (vc.allRedirectEnquiries ?? []) + object
                                    vc.endRefresh()
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }.dispose(in: vc.bag)
            self.fetchFaultyRedirectEnquiriesCount().bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                    if let data = json["data"] as? Int {
                        DispatchQueue.main.async {
                        print(data)
                            vc.redirectEnquiriesCount.text = "\(data )"
                        }
                    }
                }
                }else{
                    vc.redirectEnquiriesCount.text = "0"
                }
            }.dispose(in: vc.bag)
        }
        
        vc.viewWillAppear2 = { (sortType) in
            self.fetchOtherRedirectEnquiries(pageNo: vc.pageNo, sortBy: "date", sortType: sortType).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        if let enquirydata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                            if array.count == 0 {
                                DispatchQueue.main.async {
                                    vc.reachedLimit = true
                                    vc.endRefresh()
                                }
                            }else{
                                if let object = try? JSONDecoder().decode([AdminRedirectEnquiry].self, from: enquirydata) {
                                DispatchQueue.main.async {
                                    vc.allRedirectEnquiries = (vc.allRedirectEnquiries ?? []) + object
                                    vc.endRefresh()
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }.dispose(in: vc.bag)
            self.fetchOtherRedirectEnquiriesCount().bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                    if let data = json["data"] as? Int {
                        DispatchQueue.main.async {
                        print(data)
                            vc.redirectEnquiriesCount.text = "\(data )"
                        }
                    }
                }
                }else{
                    vc.redirectEnquiriesCount.text = "0"
                }
            }.dispose(in: vc.bag)
        }
        
        return vc
    }
    
    func createRedirectArtisanScene(enquiryId: Int, enquiryCode: String?, enquiryDate: String?, productCategory: String?, isAll: Bool) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "AdminEnquiryTab", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdminRedirectArtisansController") as! AdminRedirectArtisansController
        
        vc.viewWillAppear = {
            vc.enquiryCode.text = enquiryCode ?? ""
            vc.enquiryDate.text = enquiryDate ?? ""
            vc.productCategory.text = productCategory ?? ""
            if isAll {
                
                vc.enquiryDate.isHidden = true
                vc.productCategory.isHidden = true
                self.getAllArtisansRedirect(clusterId: vc.clusterFilterValue, enquiryId: enquiryId, searchString: vc.artisansSearchBar.searchTextField.text ?? "" ).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            if let enquirydata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                                if array.count == 0 {
                                    DispatchQueue.main.async {
                                        
                                        vc.endRefresh()
                                    }
                                }else{
                                    if let object = try? JSONDecoder().decode([AdminRedirectArtisan].self, from: enquirydata) {
                                    DispatchQueue.main.async {
                                        vc.allArtisans =  object
                                        vc.endRefresh()
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }.dispose(in: vc.bag)

            }else{
                self.fetchLessThanEightRatingArtisans(clusterId: vc.clusterFilterValue, searchString: vc.artisansSearchBar.searchTextField.text, enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            if let enquirydata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                                if array.count == 0 {
                                    DispatchQueue.main.async {
                                        
                                        vc.endRefresh()
                                    }
                                }else{
                                    if let object = try? JSONDecoder().decode([AdminRedirectArtisan].self, from: enquirydata) {
                                    DispatchQueue.main.async {
                                        vc.allArtisans =  object
                                        vc.endRefresh()
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }.dispose(in: vc.bag)

            }
        }
        vc.redirectEnquiry = {(userIds) in
            vc.showLoading()
            self.sendCustomEnquiry(enquiryId: enquiryId, userIds: userIds).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            print("redirected to artisans")
                            vc.hideLoading()
                            if isAll {
                               vc.popBack(toControllerType: AdminEscalationController.self)
                            }else{
                              vc.popBack(toControllerType: AdminRedirectEnquiryController.self)
                            }
                            
                        }
                    }
                    else {
                        vc.hideLoading()
                        vc.alert("Redirection failed, please try again")
                        vc.hideLoading()
                    }
                }
            }.dispose(in: vc.bag)
        }

    
        
        return vc
    }
}
