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
        
        return controller
    }
}

