//
//  AdminEscalationListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension AdminEscalationService {
    func createScene() -> UIViewController {
        let storyboard = UIStoryboard(name: "AdminEscalationTab", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminEscalationController") as! AdminEscalationController
        
        controller.viewWillAppear = {
            setupRefreshActions()
        }
        
        func setupRefreshActions() {
            var cat = "6"
            switch controller.catType {
            case .Chat:
                cat = "4,5"
            case .Payment:
                cat = "1"
            case .FaultyOrder:
                cat = "2,3,7"
            default:
                print("do nothing")
            }
            self.fetchAdminEscalation(cat: cat, pageNo: controller.pageNo, searchString: controller.escalationSearchBar.text ?? "").bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        parseAdminEscalatio(array: array)
                    }
                }
            }.dispose(in: controller.bag)
            
            self.fetchAdminEscalationCount(cat: cat, pageNo: controller.pageNo, searchString: controller.escalationSearchBar.text ?? "").bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let value = json["data"] as? Int {
                        DispatchQueue.main.async {
                            controller.escalationCountLbl.text = "\(value)"
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        func parseAdminEscalatio(array: [[String: Any]]) {
            if array.count == 0 {
                DispatchQueue.main.async {
                    controller.reachedLimit = true
                    refreshEnquiryList()
                }
            }else {
                var i = 0
                var idsArray: [Int] = []
                array .forEach { (obj) in
                    i+=1
                    if let userdata = try? JSONSerialization.data(withJSONObject: obj, options: .fragmentsAllowed) {
                        if let escalation = try? JSONDecoder().decode(AdminEscalation.self, from: userdata) {
                            DispatchQueue.main.async {
                                escalation.saveOrUpdate()
                                idsArray.append(escalation.entityID)
                                if i == array.count {
                                    if controller.pageNo == 1 {
                                        controller.eqArray = idsArray
                                    }else {
                                        controller.eqArray.append(contentsOf: idsArray)
                                    }
                                    refreshEnquiryList()
                                }
                            }
                        }else {
                            print("Enquiry Obj not saved: \(obj)")
                        }
                    }
                }
            }
        }
        
        func refreshEnquiryList() {
            let realm = try? Realm()
            controller.allEscalations = realm?.objects(AdminEscalation.self).filter("%K IN %@","entityID",controller.eqArray).sorted(byKeyPath: "date", ascending: false)
            controller.tableView.reloadData()
        }
        
        controller.showUser = { (enquiryId, isArtisan) in
            controller.showLoading()
            let service = AdminEnquiryListService.init(client: self.client)
            service.showUser(vc: controller, isArtisan: isArtisan, enquiryId: enquiryId)
        }
        
        controller.resolveEscalation = { (escalationId) in
            controller.showLoading()
            self.resolveEscalation(escalationId: escalationId).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            controller.view.hideAdminResolveConcernView()
                            controller.viewWillAppear?()
                            controller.hideLoading()
                        }
                    }
                }
                else {
                    controller.alert("Sending message failed, please try again later")
                    controller.hideLoading()
                }
            }.dispose(in: controller.bag)
        }
        
        controller.generateEnquiryFaulty = { (enquiryId) in
            controller.showLoading()
            self.generateNewEnquiryFaulty(enquiryId: enquiryId).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let data = json["data"] as? [String: Any] {
                            if let enquiryCode = data["code"] as? String{
                                print(enquiryCode)
                                if let productId = data["productId"] as? Int{
                                    print(productId)
                                    if let enquiryId = data["id"] as? Int{
                                        print(enquiryId)
                                        DispatchQueue.main.async {
                                            print(enquiryCode)
                                            print(productId)
                                            print(enquiryId)
                                            controller.hideLoading()
                                            controller.view.hideUnresolvedEnquiryRedirectionView()
                                            controller.view.showNewEnquiryDetailsView(enquiryCode: enquiryCode, productId: productId, isCustom: false, enquiryId: enquiryId, controller: controller)
                                        }
                                    }
                                    
                                }else{
                                    if let customProductId = data["customProductId"] as? Int{
                                        print(customProductId)
                                        if let enquiryId = data["id"] as? Int{
                                            print(enquiryId)
                                            DispatchQueue.main.async {
                                                print(enquiryCode)
                                                print(customProductId)
                                                controller.hideLoading()
                                                controller.view.hideUnresolvedEnquiryRedirectionView()
                                                controller.view.showNewEnquiryDetailsView(enquiryCode: enquiryCode, productId: customProductId, isCustom: true, enquiryId: enquiryId, controller: controller)
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                    }else{
                        controller.hideLoading()
                        controller.alert("Sorry, could not create new enquiry")
                    }
                }
                
            }.dispose(in: controller.bag)
        }
        
        return controller
    }
}

