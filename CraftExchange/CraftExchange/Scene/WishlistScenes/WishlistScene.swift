//
//  WishlistScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 20/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension WishlistService {
    func createScene() -> UIViewController {

        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "WishlistController") as! WishlistController

        func setupRefreshActions() {
           syncData()
        }
        
        func performSync() {
            fetchAllWishlistProducts().toLoadingSignal().consumeLoadingState(by: controller)
                .bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                      if let array = json["data"] as? [[String: Any]] {
                        var finalArray: [Int] = []
                        array.forEach { (dataDict) in
                            if let prodDict = dataDict["product"] as? [String: Any] {
                                if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                                    if let prodObj = try? JSONDecoder().decode(Product.self, from: proddata) {
                                        DispatchQueue.main.async {
                                            prodObj.saveOrUpdate()
                                            finalArray.append(prodObj.entityID)
                                            if finalArray.count == array.count {
                                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                                    appDelegate.wishlistIds = finalArray
                                                }
                                                controller.endRefresh()
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                      }
                    }
            }.dispose(in: controller.bag)
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
        
        controller.viewModel.viewWillAppear = {
            syncData()
        }
 
        controller.viewModel.removeAllWishlistProducts = {
            self.deleteAllWishlistProducts().toLoadingSignal().consumeLoadingState(by: controller)
            .bind(to: controller, context: .global(qos: .background)) { _, responseData in
                DispatchQueue.main.async {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            DispatchQueue.main.async {
                                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                appDelegate?.wishlistIds?.removeAll()
                                controller.endRefresh()
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        controller.title = "Your Wish list".localized
        
        controller.viewModel.deleteWishlistProduct = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.removeProductFromWishlist(prodId: prodId).observeNext { (attachment) in
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    if let index = appDelegate?.wishlistIds?.firstIndex(where: { (obj) -> Bool in
                        obj == prodId
                    }) {
                        appDelegate?.wishlistIds?.remove(at: index)
                    }
                    syncData()
                    controller.endRefresh()
                }
            }.dispose(in: controller.bag)
        }
        
        controller.viewModel.checkEnquiry = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.checkEnquiryExists(for: controller, prodId: prodId, isCustom: false)
        }
        
        controller.viewModel.generateNewEnquiry = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.generateNewEnquiry(controller: controller, prodId: prodId, isCustom: false)
        }
        
        return controller
    }
}


