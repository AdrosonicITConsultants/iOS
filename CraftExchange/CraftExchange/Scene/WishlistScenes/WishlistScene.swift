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
        
        controller.viewModel.openNewEnquiry = { (enquiryId) in
            self.showEnquiry(enquiryId: enquiryId, controller: controller)
        }
        
        return controller
    }
    
    public func showEnquiry(enquiryId: Int, controller: UIViewController) {
        let service = EnquiryDetailsService.init(client: self.client)
        service.getOpenEnquiryDetails(enquiryId: enquiryId).bind(to: controller, context: .global(qos: .background)) {(_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let eqArray = json["data"] as? [[String: Any]] {
                    if let eqObj = eqArray.first {
                    if let eqDictionary = eqObj["openEnquiriesResponse"] {
                    if let eqdata = try? JSONSerialization.data(withJSONObject: eqDictionary, options: .fragmentsAllowed) {
                        if let enquiryObj = try? JSONDecoder().decode(Enquiry.self, from: eqdata) {
                        DispatchQueue.main.async {
                        enquiryObj.saveOrUpdate()
                            
                        //Get Artisan Payment Account Details
                        if let accArray = eqObj["paymentAccountDetails"] as? [[String: Any]]{
                        if let accdata = try? JSONSerialization.data(withJSONObject: accArray, options: .fragmentsAllowed) {
                        if let parsedAccList = try? JSONDecoder().decode([PaymentAccDetails].self, from: accdata) {
                            //Get Artisan Product Categories
                            if let catArray = eqObj["productCategories"] as? [[String: Any]]{
                            if let catdata = try? JSONSerialization.data(withJSONObject: catArray, options: .fragmentsAllowed) {
                            if let parsedCatList = try? JSONDecoder().decode([UserProductCategory].self, from: catdata) {
                                enquiryObj.updateArtistDetails(blue: eqObj["isBlue"] as? Bool ?? false, user: eqObj["userId"] as? Int ?? 0, accDetails: parsedAccList, catIds: parsedCatList.compactMap({ $0.productCategoryId }), cluster: eqObj["clusterName"] as? String ?? "")
                                controller.hideLoading()
                                let realm = try? Realm()
                                let obj = realm?.objects(Enquiry.self).filter("%K == %@","entityID",enquiryId).first
                                let new = service.createEnquiryDetailScene(forEnquiry: obj, enquiryId: enquiryId) as! BuyerEnquiryDetailsController
                                new.modalPresentationStyle = .fullScreen
                                controller.navigationController?.pushViewController(new, animated: true)
                            }
                            }
                            }
                        }
                        }
                        }
                        }
                        }
                    }
                    }
                    }
                        
                    }
                }
            }
            DispatchQueue.main.async {
                controller.hideLoading()
            }
            
        }.dispose(in: controller.bag)
    }
}


