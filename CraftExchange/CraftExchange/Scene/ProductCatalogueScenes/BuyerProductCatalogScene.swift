//
//  BuyerProductCatalogScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 28/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension ProductCatalogService {
    
    func createScene(selectedRegion: ClusterDetails?, selectedProductCat: ProductCategory?, selectedArtisan: User?, madeByAntaran: Bool) -> UIViewController {
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BuyerProductCatalogController") as! BuyerProductCatalogController
        controller.selectedCluster = selectedRegion
        controller.selectedCategory = selectedProductCat
        controller.selectedArtisan = selectedArtisan
        controller.madeByAntaran = madeByAntaran == true ? 1 : 2
        
        func setupRefreshActions() {
//            controller.refreshControl?.reactive.controlEvents(.valueChanged).observeNext {
                syncData()
//            }.dispose(in: controller.bag)
        }

        func performSync() {
            if let category = selectedProductCat {
                fetchAllProducts(categoryId: category.entityID).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    DispatchQueue.main.async {
                    responseData .forEach { (prodObj) in
                        prodObj.saveOrUpdate()
                        if prodObj == responseData.last {
                            DispatchQueue.main.async {
                                controller.endRefresh()
                            }
                        }
                    }
                    }
                }.dispose(in: controller.bag)
            } else if let region = selectedRegion {
                fetchAllProducts(clusterId: region.entityID).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    DispatchQueue.main.async {
                      responseData .forEach { (prodObj) in
                          prodObj.saveOrUpdate()
                          if prodObj == responseData.last {
                              DispatchQueue.main.async {
                                  controller.endRefresh()
                              }
                          }
                      }
                    }
                }.dispose(in: controller.bag)
            }else if let artisan = selectedArtisan {
                fetchAllProducts(artisanId: artisan.entityID).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    DispatchQueue.main.async {
                    responseData .forEach { (prodObj) in
                        prodObj.saveOrUpdate()
                        if prodObj == responseData.last {
                            DispatchQueue.main.async {
                                controller.endRefresh()
                            }
                        }
                    }
                    }
                }.dispose(in: controller.bag)
            }
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
        
        controller.productSelected = { (prodId) in
            self.showSelectedProduct(for: controller, prodId: prodId)
        }
        
        controller.generateEnquiry = { (prodId) in
            self.checkEnquiryExists(for: controller, prodId: prodId, isCustom: false)
        }
        
        controller.generateNewEnquiry = { (prodId) in
            self.generateNewEnquiry(controller: controller, prodId: prodId, isCustom: false)
        }
        
        controller.addToWishlist = { (prodId) in
            self.addProductToWishlist(prodId: prodId).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            appDelegate?.wishlistIds?.append(prodId)
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        controller.removeFromWishlist = { (prodId) in
            self.removeProductFromWishlist(prodId: prodId).bind(to: controller, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            if let index = appDelegate?.wishlistIds?.firstIndex(where: { (obj) -> Bool in
                                obj == prodId
                            }) {
                                appDelegate?.wishlistIds?.remove(at: index)
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
        }
        
        controller.showNewEnquiry = { (enquiryId) in
            let service = WishlistService.init(client: self.client)
            service.showEnquiry(enquiryId: enquiryId, controller: controller)
        }
        
        return controller
    }
    
    public func checkEnquiryExists(for controller: UIViewController, prodId: Int, isCustom: Bool) {
        controller.view.showEnquiryInitiationView()
        self.checkIfEnquiryExists(prodId: prodId, isCustom: isCustom).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    print(json)
                    if let responseDictionary = json["data"] as? [String: Any] {
                        if responseDictionary["ifExists"] as? Int == 0 {
                            self.generateNewEnquiry(controller: controller, prodId: prodId, isCustom: isCustom)
                        }else {
                            DispatchQueue.main.async {
                                controller.view.hideEnquiryInitiationView()
                                controller.view.showEnquiryExistsView(controller: controller, prodName: responseDictionary["productName"] as? String ?? "", enquiryCode: responseDictionary["code"] as? String ?? "", enquiryId: responseDictionary["enquiryId"] as? Int ?? 0, prodId: prodId)
                            }
                        }
                    }
                }
            }
        }.dispose(in: controller.bag)
    }
    
    public func generateNewEnquiry(controller: UIViewController, prodId: Int, isCustom: Bool) {
        DispatchQueue.main.async {
            controller.view.showEnquiryInitiationView()
        }
        self.generateEnquiry(prodId: prodId, isCustom: isCustom).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let responseDictionary = json["data"] as? [String: Any] {
                        if let enquiryDictionary = responseDictionary["enquiry"] as? [String: Any] {
                            print(json)
                            DispatchQueue.main.async {
                                controller.view.hideEnquiryInitiationView()
                                controller.view.showEnquiryGenerateView(controller: controller, enquiryId: enquiryDictionary["id"] as? Int ?? 0, enquiryCode: enquiryDictionary["code"] as? String ?? "")
                            }
                        }
                    }
                }
            }
        }.dispose(in: controller.bag)
    }
    
    func showSelectedProduct(for controller: UIViewController, prodId: Int) {
        controller.showLoading()
        self.getProductDetails(prodId: prodId).bind(to: controller, context: .global(qos: .background)){ (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let prodDictionary = json["data"] as? [String: Any] {
                        if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                            if let object = try? JSONDecoder().decode(Product.self, from: proddata) {
                                DispatchQueue.main.async {
                                    object.saveOrUpdate()
                                    controller.hideLoading()
                                    do {
                                        let client = try SafeClient(wrapping: CraftExchangeClient())
                                        let vc = ProductCatalogService(client: client).createProdDetailScene(forProduct: Product.getProduct(searchId: prodId))
                                        vc.modalPresentationStyle = .fullScreen
                                        controller.navigationController?.pushViewController(vc, animated: true)
                                    }catch {
                                        print(error.localizedDescription)
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
    
    func showSelectedHistoryProduct(for controller: UIViewController, prodId: Int) {
        controller.showLoading()
        self.getHistoryProductDetails(prodId: prodId).bind(to: controller, context: .global(qos: .background)){ (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let prodDictionary = json["data"] as? [String: Any] {
                        if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                            if let object = try? JSONDecoder().decode(Product.self, from: proddata) {
                                DispatchQueue.main.async {
//                                    object.saveOrUpdate()
                                    controller.hideLoading()
                                    do {
                                        let client = try SafeClient(wrapping: CraftExchangeClient())
                                        let vc = ProductCatalogService(client: client).createProdDetailScene(forProduct: object)
                                        vc.modalPresentationStyle = .fullScreen
                                        controller.navigationController?.pushViewController(vc, animated: true)
                                    }catch {
                                        print(error.localizedDescription)
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

