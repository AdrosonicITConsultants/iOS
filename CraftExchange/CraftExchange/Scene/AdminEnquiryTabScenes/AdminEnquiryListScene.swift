//
//  AdminEnquiryListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension AdminEnquiryListService {
    func createScene() -> UIViewController {
        let storyboard = UIStoryboard(name: "AdminEnquiryTab", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminEnquiryListViewController") as! AdminEnquiryListViewController
        
        controller.viewWillAppear = {
            setupRefreshActions()
        }
        
        func setupRefreshActions() {
            var parameter: [String: Any] = ["availability": controller.selectedAvailability,
                                            "clusterId": controller.selectedCluster?.entityID ?? -1,
                                            "fromDate": controller.fromDate?.filterDateString() ?? "",
                                            "madeWithAntaran": controller.selectedCollection,
                                            "pageNo": controller.pageNo,
                                            "productCategory": controller.selectedProdCat?.entityID ?? -1,
                                            "toDate": controller.toDate?.filterDateString() ?? ""]
            switch controller.listType {
            case .OngoingEnquiries:
                parameter["statusId"] = 2
            case .ClosedEnquiries, .ClosedOrders:
                print("do nothing")
            case .OngoingOrders:
                parameter["statusId"] = 2
            case .CompletedOrders:
                parameter["statusId"] = 1
            default:
                print("do nothing")
            }
//            if !controller.isIncompleteClosed {
//                parameter["statusId"] = 2
//            }
            if let text = controller.enquirySearchBar.searchTextField.text, text != "" {
                parameter["enquiryId"] = text
            }
            if let text = controller.buyerBrandTextField.text, text != "" {
                parameter["buyerBrand"] = text
            }
            if let text = controller.artisanBrandTextField.text, text != "" {
                parameter["weaverIdOrBrand"] = text
            }
            switch controller.listType {
            case .OngoingEnquiries:
                self.fetchEnquiries(parameter: parameter).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            parseAdminEnquiry(array: array)
                        }
                    }
                }.dispose(in: controller.bag)
            case .ClosedEnquiries:
                self.fetchIncompleteClosedEnquiries(parameter: parameter).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            parseAdminEnquiry(array: array)
                        }
                    }
                }.dispose(in: controller.bag)
            case .OngoingOrders, .CompletedOrders:
                let service = AdminOrderService.init(client: self.client)
                service.fetchOrders(parameter: parameter).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            parseAdminEnquiry(array: array)
                        }
                    }
                }.dispose(in: controller.bag)
            case .ClosedOrders:
                let service = AdminOrderService.init(client: self.client)
                service.fetchIncompleteClosedOrders(parameter: parameter).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            parseAdminEnquiry(array: array)
                        }
                    }
                }.dispose(in: controller.bag)
            default:
                print("do nothing")
            }
        }
        
        func parseAdminEnquiry(array: [[String: Any]]) {
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
                        switch controller.listType {
                        case .OngoingEnquiries, .ClosedEnquiries:
                            if let enquiry = try? JSONDecoder().decode(AdminEnquiry.self, from: userdata) {
                                DispatchQueue.main.async {
                                    enquiry.saveOrUpdate()
                                    idsArray.append(enquiry.entityID)
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
                        case .OngoingOrders, .ClosedOrders, .CompletedOrders:
                            if let enquiry = try? JSONDecoder().decode(AdminOrder.self, from: userdata) {
                                DispatchQueue.main.async {
                                    enquiry.saveOrUpdate()
                                    idsArray.append(enquiry.entityID)
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
                        default:
                            print("do nothing")
                        }
                    }
                }
            }
        }
        
        func refreshEnquiryList() {
            let realm = try? Realm()
            switch controller.listType {
            case .OngoingEnquiries, .ClosedEnquiries:
                controller.allEnquiries = realm?.objects(AdminEnquiry.self).filter("%K IN %@","entityID",controller.eqArray).sorted(byKeyPath: "entityID", ascending: false)
            default:
                controller.allOrders = realm?.objects(AdminOrder.self).filter("%K IN %@","entityID",controller.eqArray).sorted(byKeyPath: "entityID", ascending: false)
            }
            controller.tableView.reloadData()
        }
        
        return controller
    }
    
    func showUser(vc: UIViewController, isArtisan: Bool, enquiryId: Int) {
        let service = AdminEnquiryListService.init(client: self.client)
        service.fetchUserDetailsForEnquiry(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                if let dataArray = json["data"] as? [[String: Any]] {
                    if let dataDict = dataArray.first {
                        DispatchQueue.main.async {
                            if let controller = vc as? BuyerEnquiryDetailsController {
                                if let eqObj = controller.enquiryObject {
                                    eqObj.updateUserDetails(pocFName: dataDict["pocFirstName"] as? String,
                                                            pocLName: dataDict["pocLastName"] as? String,
                                                            pocEmailAdd: dataDict["pocEmail"] as? String,
                                                            pocMob: dataDict["pocContact"] as? String,
                                                            artisanMob: dataDict["artisanContact"] as? String,
                                                            artisanMailAdd: dataDict["artisanMail"] as? String,
                                                            buyerMailAdd: dataDict["buyerMail"] as? String,
                                                            buyerMob: dataDict["buyerContact"] as? String,
                                                            buyerAlternateMob: dataDict["buyerAlternateContact"] as? String)
                                    vc.hideLoading()
                                    let newVC = AdminEnquiryUserDetailsController.init(style: .plain)
                                    newVC.isArtisan = isArtisan
                                    newVC.primaryEmail = isArtisan == true ? eqObj.artisanMail : eqObj.buyerMail
                                    newVC.primaryContact = isArtisan == true ? eqObj.artisanContact : eqObj.buyerContact
                                    newVC.secondaryContact = eqObj.buyerAlternateContact
                                    newVC.pocFirstName = eqObj.pocFirstName
                                    newVC.pocLastName = eqObj.pocLastName
                                    newVC.pocEmail = eqObj.pocEmail
                                    newVC.pocContact = eqObj.pocContact
                                    vc.navigationController?.pushViewController(newVC, animated: true)
                                }
                            }else {
                                vc.hideLoading()
                                let newVC = AdminEnquiryUserDetailsController.init(style: .plain)
                                newVC.isArtisan = isArtisan
                                newVC.primaryEmail = isArtisan == true ? dataDict["artisanMail"] as? String : dataDict["buyerMail"] as? String
                                newVC.primaryContact = isArtisan == true ? dataDict["artisanContact"] as? String : dataDict["buyerContact"] as? String
                                newVC.secondaryContact = dataDict["buyerAlternateContact"] as? String
                                newVC.pocFirstName = dataDict["pocFirstName"] as? String
                                newVC.pocLastName = dataDict["pocLastName"] as? String
                                newVC.pocEmail = dataDict["pocEmail"] as? String
                                newVC.pocContact = dataDict["pocContact"] as? String
                                vc.navigationController?.pushViewController(newVC, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}
