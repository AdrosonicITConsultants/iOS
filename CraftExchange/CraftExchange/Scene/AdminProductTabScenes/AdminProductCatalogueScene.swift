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

extension AdminProductCatalogueService {
    
    func createAdminProductCatalogue() -> UIViewController{
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProductCatalogueController") as! ProductCatalogueController
        
        func performSync(){
            controller.showLoading()
            CatalogueProduct.setAllArtisanProductIsDeleteTrue()
            self.getAllCatalogueProducts().bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let productarray = json["data"] as? [[String: Any]] {
                        var i = 0
                        productarray.forEach { (dataDict) in
                            i += 1
                            if let productdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                                if let productObj = try? JSONDecoder().decode(CatalogueProduct.self, from: productdata) {
                                    DispatchQueue.main.async {
                                        print("productObj: \(productObj)")
                                        productObj.saveOrUpdate()
                                        productObj.updateAddonDetails(userID: User.loggedIn()?.entityID ?? 0, isDeleted: 0)
                                        if i == productarray.count {
                                            controller.hideLoading()
                                            controller.endRefresh()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else {
                    controller.endRefresh()
                }
            }.dispose(in: controller.bag)
            
           ///controller.hideLoading()
        }
        
        func syncData() {
            guard !controller.isEditing else { return }
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
                return
            }
            performSync()
        }
        
        controller.viewWillAppear = {
            syncData()
        }
        
        return controller
    }
    
}
