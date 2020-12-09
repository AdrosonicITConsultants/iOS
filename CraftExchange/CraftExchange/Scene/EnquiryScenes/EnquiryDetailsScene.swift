//
//  EnquiryDetailsScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 12/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension EnquiryDetailsService {
    func createEnquiryDetailScene(forEnquiry: Enquiry?, enquiryId: Int) -> UIViewController {
        let vc = BuyerEnquiryDetailsController.init(style: .plain)
        vc.enquiryObject = forEnquiry
        vc.title = forEnquiry?.enquiryCode ?? ""
        vc.viewWillAppear = {
            vc.showLoading()
            let service = OrderDetailsService.init(client: self.client)
            service.getOldPIDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if responseData.count != 0 {
                    vc.containsOldPI = true
                }
            }
            if vc.isClosed {
                self.getClosedEnquiryDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
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
            self.getOpenEnquiryDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        self.pasrseEnquiryJson(json: json, vc: vc)
                    }
                }
                DispatchQueue.main.async {
                    vc.hideLoading()
                }
            }.dispose(in: vc.bag)
            vc.hideLoading()
        }
        
        vc.downloadOrder = { (enquiryId) in
            let service = OrderDetailsService.init(client: self.client)
            if vc.isClosed == false {
                service.getOpenOrderDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            service.pasrseEnquiryJson(json: json, vc: vc)
                        }
                    }
                    DispatchQueue.main.async {
                        vc.hideLoading()
                    }
                }.dispose(in: vc.bag)
            }else {
                service.getClosedOrderDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            service.pasrseEnquiryJson(json: json, vc: vc)
                        }
                    }
                    DispatchQueue.main.async {
                        vc.hideLoading()
                    }
                }.dispose(in: vc.bag)
            }
        }
        
        vc.goToOrder = { (enquiryId) in
            if let obj = Order().searchOrder(searchId: enquiryId) {
                let vc1 = OrderDetailsService(client: self.client).createOrderDetailScene(forOrder: obj, enquiryId: obj.entityID) as! OrderDetailController
                vc1.modalPresentationStyle = .fullScreen
                vc1.isClosed = vc.isClosed
                if vc.navigationController?.viewControllers.previous is OrderDetailController {
                    vc.navigationController?.popViewController(animated: true)
                } else {
                    vc.navigationController?.pushViewController(vc1, animated: true)
                }
                
            }
            
        }
        
        vc.showCustomProduct = {
            vc.showLoading()
            let service = UploadProductService.init(client: self.client)
            service.getCustomProductDetails(prodId: forEnquiry?.productId ?? 0, vc: vc)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                vc.hideLoading()
                let realm = try? Realm()
                if let object = realm?.objects(CustomProduct.self).filter("%K == %@", "entityID", forEnquiry?.productId ?? 0).first {
                    let newVC = UploadProductService(client: self.client).createCustomProductScene(productObject: object) as! UploadCustomProductController
                    newVC.fromEnquiry = true
                    newVC.modalPresentationStyle = .fullScreen
                    vc.navigationController?.pushViewController(newVC, animated: true)
                }
            }
        }
        
        vc.showProductDetails = {
            let service = ProductCatalogService.init(client: self.client)
            service.showSelectedProduct(for: vc, prodId: forEnquiry?.productId ?? 0)
            vc.hideLoading()
        }
        
        vc.showHistoryProductDetails = {
            let service = ProductCatalogService.init(client: self.client)
            service.showSelectedHistoryProduct(for: vc, prodId: forEnquiry?.historyProductId ?? 0)
            vc.hideLoading()
        }
        
        vc.closeEnquiry = { (enquiryId) in
            self.closeEnquiry(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                DispatchQueue.main.async {
                    vc.navigationController?.popViewController(animated: true)
                }
            }
        }
        vc.checkMOQ = {
            vc.showLoading()
            self.checkMOQ(enquiryId: enquiryId, vc: vc)
        }
        
        vc.checkMOQs = {
            self.getMOQs(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any]  {
                    if let array = json["data"] as? [[String: Any]] {
                        
                        if let objdata = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) {
                            if let object = try? JSONDecoder().decode([GetMOQs].self, from: objdata) {
                                var i = 0
                                for obj in array {
                                    guard let prodDict = obj["moq"] as? [String: Any] else{ return
                                    }
                                    guard let accepted = obj["accepted"] as? Bool else{
                                        return
                                    }
                                    
                                    if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                                        if let enquiryObj = try? JSONDecoder().decode(GetMOQ.self, from: proddata) {
                                            DispatchQueue.main.async {
                                                
                                                if accepted == true{
                                                    vc.getMOQs = enquiryObj
                                                    i = 1
                                                    vc.isMOQNeedToAccept = 1
                                                    vc.reloadBuyerMOQ()
                                                }
                                                //     vc.form.sectionBy(tag: <#T##String#>)
                                                
                                                
                                            }
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    
                                    if i == 0{
                                        vc.listMOQs = object
                                        vc.listMOQsFunc()
                                    }
                                }
                                
                            }
                        }
                        
                        
                        
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.sendMOQ = {
            if vc.viewModel.minimumQuantity.value != nil && vc.viewModel.minimumQuantity.value?.isNotBlank ?? false && vc.viewModel.pricePerUnit.value != nil && vc.viewModel.pricePerUnit.value?.isNotBlank ?? false &&  vc.viewModel.estimatedDays.value != nil {
                
                let minimumQuantity = vc.viewModel.minimumQuantity.value ?? ""
                let pricePerUnit = vc.viewModel.pricePerUnit.value ?? ""
                if minimumQuantity.isValidNumber && Int(vc.viewModel.minimumQuantity.value!)! > 0 {
                    if pricePerUnit.isValidNumber && Int(vc.viewModel.pricePerUnit.value!)! > 0{
                        self.sendMOQ(enquiryId: enquiryId, additionalInfo: vc.viewModel.additionalNote.value ?? "", deliveryTimeId: vc.viewModel.estimatedDays.value!.entityID , moq: Int(vc.viewModel.minimumQuantity.value!)!, ppu: vc.viewModel.pricePerUnit.value!).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                                if json["valid"] as? Bool == true {
                                    DispatchQueue.main.async {
                                        print("sent MOQ")
                                        vc.sentMOQ = 1
                                        let row = vc.form.rowBy(tag: "createMOQ6")
                                        row?.hidden = true
                                        row?.evaluateHidden()
                                        vc.form.allSections.first?.reload(with: .none)
                                        vc.reloadMOQ()
                                        vc.hideLoading()
                                    }
                                }
                                else {
                                    vc.alert("Send MOQ failed, please try again later".localized)
                                    vc.hideLoading()
                                }
                            }
                        }.dispose(in: vc.bag)
                        
                    }else {
                        vc.alert("Please enter valid price per unit".localized)
                        vc.hideLoading()
                    }
                }else {
                    vc.alert("Please enter valid minimum order quantity".localized)
                    vc.hideLoading()
                }
            }else {
                vc.alert("Please enter all mandatory fields".localized)
                vc.hideLoading()
            }
        }
        
        vc.acceptMOQ = {
            self.acceptMOQ(enquiryId: enquiryId, moqId: vc.viewModel.acceptMOQInfo.value!.moq!.id, artisanId: vc.viewModel.acceptMOQInfo.value!.artisanId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            print("MOQ accepted")
                            vc.form.sectionBy(tag: "list MOQs")?.removeAll()
                            vc.form.sectionBy(tag: "list MOQs")?.reload()
                            vc.form.rowBy(tag: "Check MOQs")?.hidden = true
                            vc.form.rowBy(tag: "Check MOQs")?.evaluateHidden()
                            vc.checkMOQs?()
                            // vc.reloadBuyerMOQ()
                            vc.view.hideAcceptMOQView()
                            vc.view.showAcceptedMOQView(controller: vc, getMOQs: vc.viewModel.acceptMOQInfo.value!)
                        }
                    }
                    else{
                        vc.hideLoading()
                        vc.view.hideAcceptMOQView()
                        vc.alert("Accept MOQ failed, please try again later")
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.viewPI = { (isOld) in
            let date = Date().ttceFormatter(isoDate: vc.enquiryObject!.lastUpdated!)
            if isOld == 1 {
                self.getPreviewPI(enquiryId: enquiryId, isOld: isOld, lastUpdatedDate: date, code: vc.enquiryObject?.enquiryCode ?? "\(enquiryId)", vc: vc, containsOld: false, raiseNewPI: false)
            }else {
                if vc.containsOldPI {
                    self.getPreviewPI(enquiryId: enquiryId, isOld: isOld, lastUpdatedDate: date, code: vc.enquiryObject?.enquiryCode ?? "\(enquiryId)", vc: vc, containsOld: true, raiseNewPI: false)
                }else {
                    self.getPreviewPI(enquiryId: enquiryId, isOld: isOld, lastUpdatedDate: date, code: vc.enquiryObject?.enquiryCode ?? "\(enquiryId)", vc: vc, containsOld: false, raiseNewPI: false)
                }
            }
        }
        
        vc.downloadPI = { (isPI, isOld) in
            self.downloadAndSharePI(vc: vc, enquiryId: enquiryId, isPI: isPI, isOld: isOld == true ? 1 : 0)
        }
        
        vc.getPI = {
            self.showPI(enquiryId: enquiryId, vc: vc)
        }
        
        return vc
    }
    
    func pasrseEnquiryJson(json: [String: Any], vc: UIViewController) {
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
                                                        if let controller = vc as? BuyerEnquiryDetailsController {
                                                            controller.reloadFormData()
                                                        }else if let controller = vc as? TransactionListController {
                                                            controller.viewModel.goToEnquiry?(enquiryObj.enquiryId)
                                                        }else if let controller = vc as? ChatDetailsController {
                                                            controller.goToEnquiry?(enquiryObj.enquiryId)
                                                        }
                                                        else if let controller = vc as? OrderDetailController {
                                                            controller.goToEnquiry?(enquiryObj.enquiryId)
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
    
    func checkMOQ(enquiryId: Int, vc:UIViewController) {
        self.getMOQ(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                if let dataDict = json["data"] as? Dictionary<String,Any>
                {
                    guard let moqObj = dataDict["moq"] as? Dictionary<String,Any> else {
                        return
                    }
                    if let moqdata = try? JSONSerialization.data(withJSONObject: moqObj, options: .fragmentsAllowed) {
                        if  let object = try? JSONDecoder().decode(GetMOQ.self, from: moqdata) {
                            DispatchQueue.main.async {
                                if let controller = vc as? BuyerEnquiryDetailsController {
                                    controller.getMOQ = object
                                    controller.assignMOQ()
                                }
                                //                                else if let controller = vc as? OrderDetailController {
                                //                                    controller.getMOQ = object
                                //                                    controller.assignMOQ()
                                //                                }
                            }
                        }
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func getPreviewPI(enquiryId: Int,isOld: Int, lastUpdatedDate: String, code: String, vc: UIViewController, containsOld: Bool, raiseNewPI: Bool) {
        self.getPreviewPI(enquiryId: enquiryId, isOld: isOld).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
            DispatchQueue.main.async {
                let object = String(data: responseData, encoding: .utf8) ?? ""
                vc.view.showAcceptedPIView(controller: vc, entityId: code, date: lastUpdatedDate , data: object, containsOld: containsOld, raiseNewPI: raiseNewPI, isPI: true)
                vc.hideLoading()
            }
            
        }.dispose(in: vc.bag)
        vc.hideLoading()
    }
    
    func showPI(enquiryId: Int, vc: UIViewController) {
        self.getPI(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                if let dataDict = json["data"] as? Dictionary<String,Any>
                {
                    if let moqdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                        if  let object = try? JSONDecoder().decode(GetPI.self, from: moqdata) {
                            DispatchQueue.main.async {
                                if let controller = vc as? BuyerEnquiryDetailsController {
                                    controller.PI = object
                                }else if let controller = vc as? OrderDetailController {
                                    controller.PI = object
                                }
                            }
                        }
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func closeOrder(enquiryId: Int, enquiryCode: String, productStatusId: Int, vc: UIViewController){
        
        self.closeOrder(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    DispatchQueue.main.async {
                        if productStatusId == 2{
                            self.completeOrder(enquiryId: enquiryId, vc: vc)
                        }else{
                            vc.hideLoading()
                            vc.view.hideCloseOrderView()
                            vc.view.showPartialRefundReceivedView(controller: vc, enquiryCode: enquiryCode, confirmQuestion: "Is Partial Refund Received?")
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func completeOrder(enquiryId: Int, vc: UIViewController){
        self.closeEnquiry(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        if let controller = vc as? ConfirmOrderReceivedController {
                            controller.view.showRatingInitaitionView(controller: controller)
                        }else{
                            vc.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func markOrderAsReceivedfunc(orderId: Int, orderRecieveDate: String, vc: UIViewController){
        self.markOrderAsReceived(orderId: orderId, orderRecieveDate: orderRecieveDate, isAutoCompleted: 0).bind(to: vc, context: .global(qos: .background)) {_,responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    DispatchQueue.main.async {
                        
                        self.completeOrder(enquiryId: orderId, vc: vc)
                        
                    }
                }
            }
        }
    }
    
    
    
}

