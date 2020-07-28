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
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                      if let obj = json["data"] as? [String: Any] {
                          if let prodArray = obj["products"] as? [[String: Any]] {
                              if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                                  if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                                      DispatchQueue.main.async {
                                          object .forEach { (prodObj) in
                                              prodObj.saveOrUpdate()
                                              if prodObj == object.last {
    //                                                    controller.dataSource = Product.allProducts(categoryId: category.entityID)
                                                  DispatchQueue.main.async {
                                                      controller.endRefresh()
                                                  }
                                              }
                                          }
                                      }
                                  }
                              }
                        }
                      }
                    }
                }.dispose(in: controller.bag)
            } else if let region = selectedRegion {
                fetchAllProducts(clusterId: region.entityID).bind(to: controller, context: .global(qos: .background)) { _, sync in
                    DispatchQueue.main.async {
                        controller.endRefresh()
                    }
                }.dispose(in: controller.bag)
            }else if let artisan = selectedArtisan {
                fetchAllProducts(artisanId: artisan.entityID).bind(to: controller, context: .global(qos: .background)) { _, sync in
                    DispatchQueue.main.async {
                        controller.endRefresh()
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
            /*
            controller.dataSource = nil
            let dataSource = TableViewRealmDataSource<Results<Product>>()
            if let category = selectedProductCat {
                controller.title = category.prodCatDescription
                controller.brandLogoImage.image = UIImage.init(named: category.prodCatDescription ?? "Saree")
                controller.dataSource = dataSource
                let results = Product.allProducts(categoryId: category.entityID)
                results.bind(to: controller.tableView, cellType: BuyerProductCell.self, using: dataSource) {
                    cell, results, indexPath in
                    let prodObj = results[indexPath.row]
                    cell.configure(prodObj)
                }.dispose(in: controller.bag)
            }else if let region = selectedRegion {
                controller.title = region.clusterDescription ?? ""
                controller.brandLogoImage.image = UIImage.init(named: region.clusterDescription ?? "Saree")
                controller.descriptionLabel.text = region.adjective
                controller.dataSource = dataSource
                let results = Product.allProducts(clusterId: region.entityID)
                results.bind(to: controller.tableView, cellType: BuyerProductCell.self, using: dataSource) {
                    cell, results, indexPath in
                    let prodObj = results[indexPath.row]
                    cell.configure(prodObj)
                }.dispose(in: controller.bag)
            }else if let artisan = selectedArtisan {
                controller.title = artisan.firstName ?? ""
                if let tag = artisan.buyerCompanyDetails.first?.logo, artisan.buyerCompanyDetails.first?.logo != "" {
                    let prodId = artisan.entityID
                    if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        controller.brandLogoImage.image = downloadedImage
                    }else {
                        do {
                            let client = try SafeClient(wrapping: CraftExchangeImageClient())
                            let service = BrandLogoService.init(client: client, userObject: selectedArtisan!)
                            service.fetch().observeNext { (attachment) in
                                DispatchQueue.main.async {
                                    let tag = selectedArtisan?.buyerCompanyDetails.first?.logo ?? "name.jpg"
                                    let prodId = selectedArtisan?.entityID ?? 0
                                    _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    controller.brandLogoImage.image = UIImage.init(data: attachment)
                                }
                            }.dispose(in: self.bag)
                        }catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else if let tag = artisan.profilePic, artisan.profilePic != "" {
                    let prodId = artisan.entityID
                    if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        controller.brandLogoImage.image = downloadedImage
                    }else {
                        do {
                            let client = try SafeClient(wrapping: CraftExchangeImageClient())
                            let service = UserProfilePicService.init(client: client, userObject: selectedArtisan!)
                            service.fetch().observeNext { (attachment) in
                                DispatchQueue.main.async {
                                    let tag = artisan.profilePic ?? "name.jpg"
                                    let prodId = artisan.entityID
                                    _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    controller.brandLogoImage.image = UIImage.init(data: attachment)
                                }
                            }.dispose(in: self.bag)
                        }catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                controller.dataSource = dataSource
                let results = Product.allProducts(artisanId: artisan.entityID)
                results.bind(to: controller.tableView, cellType: BuyerProductCell.self, using: dataSource) {
                    cell, results, indexPath in
                    let prodObj = results[indexPath.row]
                    cell.configure(prodObj)
                }.dispose(in: controller.bag)
            }*/
        }
        
        return controller
    }
}

