//
//  AdvancePaymentScene.swift
//  CraftExchange
//
//  Created by Kalyan on 06/10/20.
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
    
    func createPaymentScene(enquiryId: Int)-> UIViewController {
        let vc = PaymentUploadController.init(style: .plain)
        
        vc.uploadReciept = { (typeId) in
            if vc.viewModel.imageData.value != nil {
                self.uploadReceipt(enquiryId: enquiryId, type: typeId, paidAmount: Int(vc.viewModel.paidAmount.value!)!, percentage: Int(vc.viewModel.percentage.value!)!, invoiceId: Int(vc.viewModel.invoiceId.value!)!, pid: Int(vc.viewModel.pid.value!)!, totalAmount: Int(vc.viewModel.totalAmount.value!)!, imageData: vc.viewModel.imageData.value, filename: vc.viewModel.fileName.value).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            DispatchQueue.main.async {
                                
                                vc.form.rowBy(tag: "uploadReceipt")?.hidden = true
                                vc.form.rowBy(tag: "uploadReceipt")?.evaluateHidden()
                                vc.form.rowBy(tag: "uploadsuccess")?.hidden = false
                                vc.form.rowBy(tag: "uploadsuccess")?.evaluateHidden()
                                vc.form.allSections.first?.reload(with: .none)
                                if typeId == 1{
                                     vc.imageReciept?(1)
                                    let viewControllers = vc.navigationController!.viewControllers
                                                                   vc.navigationController!.viewControllers.remove(at: viewControllers.count - 2)
                                }else{
                                  vc.imageReciept?(2)
                                }
                                vc.hideLoading()
                            }
                        }
                    }
                }.dispose(in: vc.bag)
            }
            else {
                vc.alert("Please upload image")
                vc.hideLoading()
            }
        }
        
        vc.uploadDeliveryReciept = {
             if vc.viewModel.imageData.value != nil {
                if vc.viewModel.orderDispatchDate.value != nil {
                    self.uploadDeliveryChallan(enquiryId: enquiryId, orderDispatchDate: vc.viewModel.orderDispatchDate.value!, ETA: vc.viewModel.ETA.value!, imageData: vc.viewModel.imageData.value, filename: vc.viewModel.fileName.value).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if json["valid"] as? Bool == true {
                                DispatchQueue.main.async {
                                    
                                    vc.hideLoading()
                                    vc.popBack(toControllerType: OrderDetailController.self)
                                }
                            }
                        }
                    }.dispose(in: vc.bag)
                    vc.hideLoading()
                    vc.popBack(toControllerType: OrderDetailController.self)
                }else {
                    vc.alert("Please fill in dispatch order date")
                    vc.hideLoading()
                }
            }else {
                vc.alert("Please upload image")
                vc.hideLoading()
            }
            
        }
        
        vc.imageReciept = { (typeId) in
            self.downloadAndViewReceipt(vc: vc, enquiryId: enquiryId, typeId: typeId)
        }
        
        return vc
    }
    
    func downloadAndViewReceipt(vc: UIViewController, enquiryId: Int, typeId: Int) {
        if typeId == 1 {
            self.ImgReceit(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    
                    if let dataDict = json["data"] as? Dictionary<String,Any>
                    {
                        if let recieptdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                            
                            if  let object = try? JSONDecoder().decode(PaymentArtist.self, from: recieptdata) {
                                DispatchQueue.main.async {
                                    print("hey:\(object)")
                                    if let controller = vc as? PaymentUploadController {
                                        controller.receipt = object
                                    }
                                    let name = object.label
                                    let paymentID = object.paymentId
                                
                                    let url = URL(string: KeychainManager.standard.imageBaseURL + "/AdvancedPayment/\(paymentID)/" + name!)
                                    URLSession.shared.dataTask(with: url!) { data, response, error in
                                        DispatchQueue.main.async {
                                            if error == nil {
                                                if let finalData = data {
                                                    if let controller = vc as? PaymentUploadController {
                                                        controller.data = finalData
                                                    }else if let controller = vc as? TransactionListController {
                                                        controller.hideLoading()
                                                        controller.view.showTransactionReceiptView(controller: controller, data: finalData)
                                                    }else if let controller = vc as? PaymentArtistController{
                                                        //controller.hideLoading()
                                                        let row = controller.form.rowBy(tag: "PaymentArtist-1") as? ArtistReceitImgRow
                                                                            row?.cell.ImageReceit.image = UIImage(data: finalData)
                                                       //  controller.hideLoading()
                                                      
                                                    }
                                                }
                                            }
                                        }
                                    }.resume()
                                }
                            }
                        }
                    }
                }
            }

        }
        else{
            self.FinalPaymentReceit(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    
                    if let dataDict = json["data"] as? Dictionary<String,Any>
                    {
                        if let recieptdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                            
                            if  let object = try? JSONDecoder().decode(PaymentArtist.self, from: recieptdata) {
                                DispatchQueue.main.async {
                                    print("hey:\(object)")
                                    if let controller = vc as? PaymentUploadController {
                                        controller.receipt = object
                                    }
                                    let name = object.label
                                    let paymentID = object.paymentId
                                
                                    let url = URL(string: KeychainManager.standard.imageBaseURL + "/FinalPayment/\(paymentID)/" + name!)
                                    URLSession.shared.dataTask(with: url!) { data, response, error in
                                        DispatchQueue.main.async {
                                            if error == nil {
                                                if let finalData = data {
                                                    if let controller = vc as? PaymentUploadController {
                                                        controller.data = finalData
                                                    }else if let controller = vc as? TransactionListController {
                                                        controller.hideLoading()
                                                        controller.view.showTransactionReceiptView(controller: controller, data: finalData)
                                                    }else if let controller = vc as? PaymentArtistController{
                                                        //controller.hideLoading()
                                                        let row = controller.form.rowBy(tag: "PaymentArtist-1") as? ArtistReceitImgRow
                                                                            row?.cell.ImageReceit.image = UIImage(data: finalData)
                                                        print(finalData)
                                                       //  controller.hideLoading()
                                                      
                                                    }
                                                }
                                            }
                                        }
                                    }.resume()
                                }
                            }
                        }
                    }
                }
            }

        }
        
    }
    
    func advancePaymentStatus(vc: UIViewController, enquiryId: Int) {
        self.getAdvancePaymentStatus(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
        
        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
            
            if let dataDict = json["data"] as? Dictionary<String,Any>
            {
                if let paymentdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                    
                    if  let object = try? JSONDecoder().decode(PaymentStatus.self, from: paymentdata) {
                                DispatchQueue.main.async {
                                    print("hey:\(object)")
                                    if let controller = vc as? PaymentArtistController{
                                       // controller.hideLoading()
                                        let row = controller.form.rowBy(tag: "PaymentArtist-1") as? ArtistReceitImgRow
                                        row?.cell.AmountLabel.text = "Amount to be Paid as per PI: \(object.paidAmount)"
                                       
                                      
                                    }else if let controller = vc as? OrderDetailController{
                                        controller.advancePaymnet = object
                                    }

                                }

                            }

                        }

                    }
            }
            
        }.dispose(in: vc.bag)
    }
    
    func finalPaymentDetails(vc: UIViewController, enquiryId: Int) {
        self.getFinalPaymentDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
        
        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
            
            if let dataDict = json["data"] as? Dictionary<String,Any>
            {
                if let finalpaymentdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                    
                    if  let object = try? JSONDecoder().decode(FinalPaymentDetails.self, from: finalpaymentdata) {
                                DispatchQueue.main.async {
                                    print("hey:\(object)")
                                    if let controller = vc as? OrderDetailController{
                                        controller.finalPaymnetDetails = object
                                    }

                                }

                            }

                        }

                    }
            }
            
        }.dispose(in: vc.bag)
    }
    
    func finalPaymentStatus(vc: UIViewController, enquiryId: Int) {
        self.getFinalPaymentStatus(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
        
        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
            
            if let dataDict = json["data"] as? Dictionary<String,Any>
            {
                if let paymentdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                    
                    if  let object = try? JSONDecoder().decode(PaymentStatus.self, from: paymentdata) {
                                DispatchQueue.main.async {
                                    print("hey:\(object)")
                                    if let controller = vc as? PaymentArtistController{
                                       // controller.hideLoading()
                                        let row = controller.form.rowBy(tag: "PaymentArtist-1") as? ArtistReceitImgRow
                                        row?.cell.AmountLabel.text = "Amount to be Paid as per Final Invoice: \(object.paidAmount)"
                                       
                                      
                                    }else if let controller = vc as? OrderDetailController{
                                        controller.finalPaymnet = object
                                    }

                                }

                            }

                        }

                    }
            }
            
        }.dispose(in: vc.bag)
    }
    
    func validatePaymentFunc(vc: UIViewController,typeId: Int, enquiryId: Int, status: Int) {
        if typeId == 2{
            self.validateFinalPayment(enquiryId: enquiryId, status: status).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if json["valid"] as? Bool == true {
                                DispatchQueue.main.async {
                                    vc.hideLoading()
                                    vc.popBack(toControllerType: OrderDetailController.self)
                                }
                            }
                        }
                    }.dispose(in: vc.bag)
        }else{
            self.validateAdvancePayment(enquiryId: enquiryId, status: status).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if json["valid"] as? Bool == true {
                                DispatchQueue.main.async {
                                    vc.hideLoading()
                                    vc.popBack(toControllerType: OrderDetailController.self)
                                }
                            }
                        }
                    }.dispose(in: vc.bag)
        }
        
    }
    
    func changeInnerStageFunc(vc: UIViewController, enquiryId: Int, stageId: Int, innerStageId: Int) {
        self.changeInnerStage(enquiryId: enquiryId, stageId: stageId, innerStageId: innerStageId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        if let controller = vc as? BuyerEnquiryDetailsController {
                            controller.viewWillAppear?()
                        }
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
}
