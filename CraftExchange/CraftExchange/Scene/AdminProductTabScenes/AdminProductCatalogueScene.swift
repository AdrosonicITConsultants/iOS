//
//  AdminProductCatalogueScene.swift
//  CraftExchange
//
//  Created by Kalyan on 20/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit
import Realm
import RealmSwift

extension AdminProductCatalogueService {
    
    func createAdminProductCatalogue() -> UIViewController{
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProductCatalogueController") as! ProductCatalogueController
        
        controller.viewWillAppear = {
            setupRefreshActions()
        }
        
        func setupRefreshActions(){

            var parameters: [String: Any] = ["availability": controller.availabilityFilterValue,
                                            "clusterId": controller.clusterFilterValue,
                                            "pageNo": controller.pageNo,
                                            "sortBy": "date",
                                            "sortType": "desc"]
            if controller.segmentView.selectedSegmentIndex == 0 {
                parameters["madeWithAntaran"] = 0
            }else {
                parameters["madeWithAntaran"] = 1
            }
            
            if let text = controller.productSearchBar.searchTextField.text, text != "" {
                parameters["searchStr"] = text
            }
            
            CatalogueProduct.setAllArtisanProductIsDeleteTrue()
            
            self.fetchCatalogueProducts(parameters: parameters).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let productarray = json["data"] as? [[String: Any]] {
                        if productarray.count == 0 {
                            DispatchQueue.main.async {
                                controller.reachedLimit = true
                                refreshEnquiryList()
                            }
                        }else {
                        var i = 0
                        var idsArray: [Int] = []
                        productarray.forEach { (dataDict) in
                            i += 1
                            if let productdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                                if let productObj = try? JSONDecoder().decode(CatalogueProduct.self, from: productdata) {
                                    DispatchQueue.main.async {
                                        print("productObj: \(productObj)")
                                        productObj.saveOrUpdate()
                                        productObj.updateAddonDetails(userID: User.loggedIn()?.entityID ?? 0, isDeleted: 0)
                                        idsArray.append(productObj.entityID)
                                        if i == productarray.count {

                                            if controller.pageNo == 1 {
                                                controller.eqArray = idsArray
                                            }else {
                                                controller.eqArray.append(contentsOf: idsArray)
                                            }
                                            refreshEnquiryList()
                                        }
                                    }
                                }else {
                                    print("Product Obj not saved: \(dataDict)")
                                }
                            }
                        }
                    }
                    }
                }
            }.dispose(in: controller.bag)
            
            self.fetchCatalogueProductsCount(parameters: parameters).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let dataValue = json["data"] as? Int {
                        DispatchQueue.main.async {
                        controller.totalLabel.text = "Total Products: \(dataValue)"
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        func refreshEnquiryList() {
            let realm = try? Realm()
            
                    controller.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K IN %@","entityID",controller.eqArray).sorted(byKeyPath: "entityID", ascending: false)
                    controller.allProducts = controller.allProductsResults?.compactMap({$0})
            
            controller.tableView.reloadData()
        }
        
//        func syncData() {
//            guard !controller.isEditing else { return }
//            guard controller.reachabilityManager?.connection != .unavailable else {
//                DispatchQueue.main.async {
//                    controller.endRefresh()
//                }
//                return
//            }
//            performSync()
//        }
        
        
        
        return controller
    }
    
}
