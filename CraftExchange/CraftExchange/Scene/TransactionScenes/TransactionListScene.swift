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
                            if array.count == 0 {
                                DispatchQueue.main.async {
                                    controller.endRefresh()
                                }
                            }
                            else {
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
                                                    transactionObj.updateAddonDetails(userID: User.loggedIn()?.entityID ?? 0)
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
        
        controller.viewModel.viewTransactionReceipt = { (transaction, isOld, isPI) in
            let service = EnquiryDetailsService.init(client: self.client)
            if isPI {
                service.getPreviewPI(enquiryId: transaction.enquiryId, isOld: isOld).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    DispatchQueue.main.async {
                        let object = String(data: responseData, encoding: .utf8) ?? ""
                        controller.view.showAcceptedPIView(controller: controller, entityId: transaction.orderCode ?? "\(transaction.enquiryId)", date: Date().ttceISOString(isoDate: transaction.modifiedOn ?? Date()) , data: object, containsOld: false, raiseNewPI: false, isPI: true)
                        controller.hideLoading()
                    }
                }.dispose(in: controller.bag)
                controller.hideLoading()
            }else{
                service.getViewFI(enquiryId: transaction.enquiryId, isOld: isOld).toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    DispatchQueue.main.async {
                        let object = String(data: responseData, encoding: .utf8) ?? ""
                        controller.view.showAcceptedPIView(controller: controller, entityId: transaction.orderCode ?? "\(transaction.enquiryId)", date: Date().ttceISOString(isoDate: transaction.modifiedOn ?? Date()) , data: object, containsOld: false, raiseNewPI: false, isPI: false)
                        controller.hideLoading()
                    }
                }.dispose(in: controller.bag)
                controller.hideLoading()
            }
        }
        
        controller.viewModel.downloadPI = { (enquiryId, isPI) in
            let service = EnquiryDetailsService.init(client: self.client)
            service.downloadAndSharePI(vc: controller, enquiryId: enquiryId, isPI: isPI, isOld: 0)
        }
        
        controller.viewModel.downloadEnquiry = { (enquiryId) in
            let service = EnquiryDetailsService.init(client: self.client)
            service.getOpenEnquiryDetails(enquiryId: enquiryId).bind(to: controller, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        service.pasrseEnquiryJson(json: json, vc: controller)
                    }
                }
                DispatchQueue.main.async {
                    controller.hideLoading()
                }
            }.dispose(in: controller.bag)
        }
        
        controller.viewModel.goToEnquiry = { (enquiryId) in
            if let obj = Enquiry().searchEnquiry(searchId: enquiryId ) {
                let vc = EnquiryDetailsService(client: self.client).createEnquiryDetailScene(forEnquiry: obj, enquiryId: obj.entityID) as! BuyerEnquiryDetailsController
                vc.modalPresentationStyle = .fullScreen
                vc.isClosed = false
                controller.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        controller.viewModel.downloadAdvReceipt = { (enquiryId) in
            let service = EnquiryDetailsService.init(client: self.client)
            controller.showLoading()
            service.downloadAndViewReceipt(vc: controller, enquiryId: enquiryId, typeId: 1)
        }
        controller.viewModel.downloadRevisedAdvReceipt = { (enquiryId) in
            let service = EnquiryDetailsService.init(client: self.client)
            controller.showLoading()
            service.downloadAndViewReceipt(vc: controller, enquiryId: enquiryId, typeId: 3)
        }
        controller.viewModel.downloadFinalReceipt = { (enquiryId) in
            let service = EnquiryDetailsService.init(client: self.client)
            controller.showLoading()
            service.downloadAndViewReceipt(vc: controller, enquiryId: enquiryId, typeId: 2)
        }
        
        return controller
    }
}



