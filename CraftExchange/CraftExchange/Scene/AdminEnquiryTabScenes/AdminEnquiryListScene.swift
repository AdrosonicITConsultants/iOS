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
                                            "statusId": 2,
                                            "toDate": controller.toDate?.filterDateString() ?? ""]
            if let text = controller.enquirySearchBar.searchTextField.text, text != "" {
                parameter["enquiryId"] = text
            }
            if let text = controller.buyerBrandTextField.text, text != "" {
                parameter["buyerBrand"] = text
            }
            if let text = controller.artisanBrandTextField.text, text != "" {
                parameter["weaverIdOrBrand"] = text
            }
            if controller.isIncompleteClosed {
                self.fetchIncompleteClosedEnquiries(parameter: parameter).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            parseAdminEnquiry(array: array)
                        }
                    }
                }.dispose(in: controller.bag)
            }else {
                self.fetchEnquiries(parameter: parameter).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            parseAdminEnquiry(array: array)
                        }
                    }
                }.dispose(in: controller.bag)
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
                    }
                }
            }
        }
        
        func refreshEnquiryList() {
            let realm = try? Realm()
            controller.allEnquiries = realm?.objects(AdminEnquiry.self).filter("%K IN %@","entityID",controller.eqArray).sorted(byKeyPath: "entityID", ascending: false)
            controller.tableView.reloadData()
        }
        
        return controller
    }
}