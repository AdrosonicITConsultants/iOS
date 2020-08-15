//
//  CustomProductListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension CustomProductService {
    func createScene() -> UIViewController {
        let controller = CustomProductListController.init(style: .plain)

        func setupRefreshActions() {
            controller.refreshControl?.reactive.controlEvents(.valueChanged).observeNext {
                syncData()
            }.dispose(in: controller.bag)
        }
        
        func performSync() {
            fetchAllBuyersCustomProduct().toLoadingSignal().consumeLoadingState(by: controller)
                .bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                      if let array = json["data"] as? [[String: Any]] {
                          if let proddata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                              if let object = try? JSONDecoder().decode([CustomProduct].self, from: proddata) {
                                  DispatchQueue.main.async {
                                      object .forEach { (prodObj) in
                                          prodObj.saveOrUpdate()
                                          if prodObj == object.last {
                                              controller.endRefresh()
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
        
        controller.viewWillAppear = {
            syncData()
        }
        
        controller.title = "Custom products".localized
        controller.dataSource = nil
        let dataSource = TableViewRealmDataSource<Results<CustomProduct>>()
        controller.dataSource = dataSource
        let results = CustomProduct.allBuyerProducts()
        results.bind(to: controller.tableView, cellType: BuyerProductCell.self, using: dataSource) {
            cell, results, indexPath in
            let prodObj = results[indexPath.row]
            cell.configure(prodObj)
        }.dispose(in: controller.bag)
        
        controller.tableView.reactive.selectedRowIndexPath
        .bind(to: controller, context: .immediateOnMain) { _, indexPath in
            guard let object = dataSource.changeset?[indexPath.row] else { return }
            let vc = UploadProductService(client: self.client).createCustomProductScene(productObject: object)
            vc.modalPresentationStyle = .fullScreen
            controller.navigationController?.pushViewController(vc, animated: true)
        }.dispose(in: controller.bag)
        
        return controller
    }
}
