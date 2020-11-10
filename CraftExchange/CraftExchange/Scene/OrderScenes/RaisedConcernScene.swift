//
//  RaisedConcernScene.swift
//  CraftExchange
//
//  Created by Kalyan on 05/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit
import Eureka

extension OrderDetailsService {
    func createRaiseConcernScene(forOrder: Order?, enquiryId: Int) -> UIViewController {
        
        let vc = RaiseConcernController.init(style: .plain)
        vc.orderObject = forOrder
        
        vc.viewWillAppear = {
            vc.showLoading()
            
            self.getOrderProgress(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let dataDict = json["data"] as? Dictionary<String,Any>
                    {
                        guard let moqObj = dataDict["orderProgress"] as? Dictionary<String,Any> else {
                            return
                        }
                        if let orderData = try? JSONSerialization.data(withJSONObject: moqObj, options: .fragmentsAllowed) {
                            if  let object = try? JSONDecoder().decode(OrderProgress.self, from: orderData) {
                                DispatchQueue.main.async {
                                    print("orderProgress: \(object)")
                                    
                                    vc.orderProgress = object
                                    vc.reloadFormData()
                                    vc.hideLoading()
                                }
                            }
                        }
                    }
                }
            }.dispose(in: vc.bag)
            
            
        }
        vc.getOrderProgress = {
            vc.showLoading()
            self.getOrderProgress(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let dataDict = json["data"] as? Dictionary<String,Any>
                    {
                        guard let moqObj = dataDict["orderProgress"] as? Dictionary<String,Any> else {
                            return
                        }
                        if let orderData = try? JSONSerialization.data(withJSONObject: moqObj, options: .fragmentsAllowed) {
                            if  let object = try? JSONDecoder().decode(OrderProgress.self, from: orderData) {
                                DispatchQueue.main.async {
                                    print("orderProgress: \(object)")
                                    
                                    vc.orderProgress = object
                                    vc.reloadFormData()
                                    vc.hideLoading()
                                    
                                }
                            }
                        }
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.sendBuyerReview = {
            if vc.viewModel.buyerReviewId.value != nil && vc.viewModel.buyerReviewId.value != "" && vc.viewModel.buyerReviewId.value?.isNotBlank ?? false {
                if vc.viewModel.buyerComment.value != nil && vc.viewModel.buyerComment.value?.isNotBlank ?? false{
                    vc.view.showBuyerReviewConfirmView(controller: vc)
                    
                }else{
                    vc.alert("Please write comment".localized)
                    vc.hideLoading()
                }
            }else{
                vc.alert("Please select at least one option".localized)
                vc.hideLoading()
            }
        }
        
        vc.sendConfirmBuyerReview = {
            vc.showLoading()
            self.sendBuyerFaultyReview(orderId: vc.orderObject!.enquiryId, buyerComment: vc.viewModel.buyerComment.value!, multiCheck:vc.viewModel.buyerReviewId.value! ).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            print("sent Review")
                            vc.view.hideBuyerReviewConfirmView()
                            vc.hideLoading()
                            vc.viewWillAppear?()
                        }
                    }
                    else {
                        vc.hideLoading()
                        vc.alert("Sending review for faulty orde failed, please try again later")
                        vc.hideLoading()
                    }
                }
            }.dispose(in: vc.bag)
            
        }
        
        vc.sendArtisanReview = {
            if vc.viewModel.artisanReviewId.value != nil {
                if vc.viewModel.artisanComment.value != nil && vc.viewModel.artisanComment.value?.isNotBlank ?? false{
                    vc.showLoading()
                    self.sendArtisanReview(orderId: vc.orderObject!.enquiryId, artisanReviewComment: vc.viewModel.artisanComment.value!, multiCheck: vc.viewModel.artisanReviewId.value!.id).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if json["valid"] as? Bool == true {
                                DispatchQueue.main.async {
                                    print("sent Review")
                                    
                                    vc.hideLoading()
                                    
                                    if vc.viewModel.artisanReviewId.value!.id == "2"{
                                        vc.view.showPartialRefundReceivedView(controller: vc, enquiryCode: forOrder?.orderCode, confirmQuestion: "Are you sure you want to recreate order?".localized)
                                    }
                                    vc.viewWillAppear?()
                                }
                            }
                            else {
                                vc.showLoading()
                                vc.alert("Sending review for faulty order failed, please try again later".localized)
                                vc.hideLoading()
                            }
                        }
                    }.dispose(in: vc.bag)
                    
                }else{
                    vc.alert("Please write comment".localized)
                    vc.hideLoading()
                }
            }else{
                vc.alert("Please select at least one option".localized)
                vc.hideLoading()
            }
        }
        
        vc.markResolved = {
            vc.showLoading()
            self.markConcernResolved(orderId: enquiryId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            vc.hideLoading()
                            vc.view.hideCloseOrderView()
                            vc.viewWillAppear?()
                            
                        }
                    }
                }
            }
            
        }
        
        return vc
    }
    
}
