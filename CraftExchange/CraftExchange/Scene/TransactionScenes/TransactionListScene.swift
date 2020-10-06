//
//  TransactionListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension TransactionService {
    func createScene() -> UIViewController {

        let storyboard = UIStoryboard(name: "Transaction", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TransactionListController") as! TransactionListController

        func setupRefreshActions() {
           syncData()
        }
        
        func performSync() {
            getAllOngoingTransactions().toLoadingSignal().consumeLoadingState(by: controller)
                .bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                      if let array = json["data"] as? [[String: Any]] {
                        var finalArray: [Int] = []
                        array.forEach { (dataDict) in
                            if let transactionDict = dataDict["transactionOngoing"] as? [String: Any] {
                                if let transactiondata = try? JSONSerialization.data(withJSONObject: transactionDict, options: .fragmentsAllowed) {
                                    if var transactionObj = try? JSONDecoder().decode(TransactionObject.self, from: transactiondata) {
                                        DispatchQueue.main.async {
                                            transactionObj.enquiryCode = dataDict["enquiryCode"] as? String
                                            transactionObj.eta = dataDict["eta"] as? String
                                            transactionObj.orderCode = dataDict["orderCode"] as? String
                                            transactionObj.paidAmount = dataDict["paidAmount"] as? Int ?? 0
                                            transactionObj.percentage = dataDict["percentage"] as? Int ?? 0
                                            transactionObj.totalAmount = dataDict["totalAmount"] as? Int ?? 0
                                            transactionObj.saveOrUpdate()
                                            finalArray.append(transactionObj.enquiryId)
                                            if finalArray.count == array.count {
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
        
        return controller
    }
}



