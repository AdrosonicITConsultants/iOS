//
//  OrderDetailsScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension OrderDetailsService {
    func createOrderDetailScene(forOrder: Order?, enquiryId: Int) -> UIViewController {
        
        let vc = OrderDetailController.init(style: .plain)
        vc.orderObject = forOrder
        
        vc.viewWillAppear = {
            vc.showLoading()
            if vc.isClosed {
                self.getClosedOrderDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            self.pasrseEnquiryJson(json: json, vc: vc)
                        }
                    }
                    DispatchQueue.main.async {
                        vc.hideLoading()
                    }
                }.dispose(in: vc.bag)
            }
            self.getOpenOrderDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        self.pasrseEnquiryJson(json: json, vc: vc)
                    }
                }
                DispatchQueue.main.async {
                    vc.hideLoading()
                }
            }.dispose(in: vc.bag)
        }
        
        vc.showCustomProduct = {
            vc.showLoading()
            let service = UploadProductService.init(client: self.client)
            service.getCustomProductDetails(prodId: forOrder?.productId ?? 0, vc: vc)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                vc.hideLoading()
                let realm = try? Realm()
                if let object = realm?.objects(CustomProduct.self).filter("%K == %@", "entityID", forOrder?.productId ?? 0).first {
                    let newVC = UploadProductService(client: self.client).createCustomProductScene(productObject: object) as! UploadCustomProductController
                    newVC.fromEnquiry = true
                    newVC.modalPresentationStyle = .fullScreen
                    vc.navigationController?.pushViewController(newVC, animated: true)
                }
            }
        }
        
        vc.showProductDetails = {
            let service = ProductCatalogService.init(client: self.client)
            service.showSelectedProduct(for: vc, prodId: forOrder?.productId ?? 0)
            vc.hideLoading()
        }
        
        vc.showHistoryProductDetails = {
            let service = ProductCatalogService.init(client: self.client)
            service.showSelectedHistoryProduct(for: vc, prodId: forOrder?.historyProductId ?? 0)
            vc.hideLoading()
        }
        
        vc.checkMOQ = {
            vc.showLoading()
            let service = EnquiryDetailsService.init(client: self.client)
            service.checkMOQ(enquiryId: enquiryId, vc: vc)
        }
        
        vc.viewPI = {
            let date = Date().ttceISOString(isoDate: vc.orderObject!.lastUpdated!)
            let service = EnquiryDetailsService.init(client: self.client)
            service.getPreviewPI(enquiryId: enquiryId, lastUpdatedDate: date, code: vc.orderObject?.orderCode ?? "\(enquiryId)", vc: vc)
        }
        
        vc.downloadPI = {
            let service = EnquiryDetailsService.init(client: self.client)
            service.downloadAndSharePI(vc: vc, enquiryId: enquiryId)
        }
        
        vc.getPI = {
            let service = EnquiryDetailsService.init(client: self.client)
            service.showPI(enquiryId: enquiryId, vc: vc)
        }
        
        vc.toggleChangeRequest = { (eqId, isEnabled) in
            vc.showLoading()
            self.toggleChangeRequest(enquiryId: eqId, isEnabled: isEnabled).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            vc.orderObject?.toggleChangeStatus(isEnabled: isEnabled)
                        }
                    }
                }
                DispatchQueue.main.async {
                    vc.hideLoading()
                }
            }.dispose(in: vc.bag)
        }
        
        vc.checkTransactions = {
            let service = TransactionService.init(client: self.client)
            service.getAllTransactionsForEnquiry(enquiryId: vc.orderObject?.enquiryId ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if let responseDict = json["data"] as? [String: Any] {
                    if let transactionArray = responseDict["ongoingTransactionResponses"] as? [[String:Any]]  {
                        var finalArray: [Int]? = []
                        transactionArray.forEach { (dataDict) in
                            if let transactionDict = dataDict["transactionOngoing"] as? [String: Any] {
                                if let transactiondata = try? JSONSerialization.data(withJSONObject: transactionDict, options: .fragmentsAllowed) {
                                    if let transactionObj = try? JSONDecoder().decode(TransactionObject.self, from: transactiondata) {
                                        DispatchQueue.main.async {
                                            transactionObj.enquiryCode = dataDict["enquiryCode"] as? String
                                            transactionObj.eta = dataDict["eta"] as? String
                                            transactionObj.orderCode = dataDict["orderCode"] as? String
                                            transactionObj.paidAmount = dataDict["paidAmount"] as? Int ?? 0
                                            transactionObj.percentage = dataDict["percentage"] as? Int ?? 0
                                            transactionObj.totalAmount = dataDict["totalAmount"] as? Int ?? 0
                                            transactionObj.saveOrUpdate()
                                            finalArray?.append(transactionObj.entityID)
                                            if finalArray?.count == transactionArray.count {
                                                let transactions = TransactionObject.getTransactionObjects(searchId: vc.orderObject?.entityID ?? 0)
                                                vc.listTransactions = transactions.compactMap({$0})
                                                vc.listTransactionsFunc()
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
            let transactions = TransactionObject.getTransactionObjects(searchId: vc.orderObject?.entityID ?? 0)
            vc.listTransactions = transactions.compactMap({$0})
        }
        
        return vc
    }
    
    func pasrseEnquiryJson(json: [String: Any], vc: UIViewController) {
        if let eqArray = json["data"] as? [[String: Any]] {
            if let eqObj = eqArray.first {
                if let eqDictionary = eqObj["openEnquiriesResponse"] {
                    if let eqdata = try? JSONSerialization.data(withJSONObject: eqDictionary, options: .fragmentsAllowed) {
                        if let enquiryObj = try? JSONDecoder().decode(Order.self, from: eqdata) {
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
                                                        if let controller = vc as? BuyerEnquiryDetailsController {
                                                            controller.reloadFormData()
                                                        }else if let controller = vc as? TransactionListController {
                                                            controller.viewModel.goToEnquiry?(enquiryObj.enquiryId)
                                                        }else if let controller = vc as? OrderDetailController {
                                                            controller.reloadFormData()
                                                        }
                                                        
                                                        vc.hideLoading()
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

