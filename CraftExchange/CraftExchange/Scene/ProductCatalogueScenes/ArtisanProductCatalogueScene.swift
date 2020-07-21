//
//  ArtisanProductCatalogueScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/07/20.
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
    func createScene(for catId: Int) -> UIViewController {
        let controller = ArtisanProdCatalogueController.init(style: .plain)
        
        guard var selectedProductCat = ProductCategory.getProductCat(catId: catId) else {
            return controller
        }

        func setupRefreshActions() {
            controller.refreshControl?.reactive.controlEvents(.valueChanged).observeNext {
                syncData()
            }.dispose(in: controller.bag)
        }
        
        func loadInitialEmails() {
            fetchAllArtisanProduct().bind(to: controller, context: .global(qos: .background)) { _, sync in
//                self.update(sync)
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
            }.dispose(in: controller.bag)
        }
        
        func performSync() {
            fetchAllArtisanProduct().toLoadingSignal().consumeLoadingState(by: controller)
                .bind(to: controller, context: .global(qos: .background)) { _, sync in
//                    self.update(sync)
                    DispatchQueue.main.async {
                        controller.endRefresh()
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
        
        controller.title = selectedProductCat.prodCatDescription
        controller.dataSource = nil
        let dataSource = TableViewRealmDataSource<Results<Product>>()
        controller.dataSource = dataSource
        let results = Product.allArtisanProducts(for: selectedProductCat.entityID)
        results.bind(to: controller.tableView, cellType: ArtisanProductCell.self, using: dataSource) {
            cell, results, indexPath in
            let prodObj = results[indexPath.row]
            cell.configure(prodObj)
        }.dispose(in: controller.bag)
        
        controller.refreshCategory = { (catId) in
            selectedProductCat = ProductCategory.getProductCat(catId: catId) ?? selectedProductCat
            let results = Product.allArtisanProducts(for: selectedProductCat.entityID)
            results.bind(to: controller.tableView, cellType: ArtisanProductCell.self, using: dataSource) {
                cell, results, indexPath in
                let prodObj = results[indexPath.row]
                cell.configure(prodObj)
            }.dispose(in: controller.bag)
        }
        
        return controller
    }
}
