//
//  InvoiceScene.swift
//  CraftExchange
//
//  Created by Kiran Songire on 23/09/20.
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
    func piCreate(enquiryId: Int, enquiryObj: Enquiry?, orderObj: Order?) -> UIViewController {
        let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InvoiceController") as! InvoiceController
        
        
        vc.viewModel.savePI = {
            
            if vc.viewModel.quantity.value != nil && vc.viewModel.quantity.value?.isNotBlank ?? false && vc.viewModel.pricePerUnitPI.value != nil && vc.viewModel.pricePerUnitPI.value?.isNotBlank ?? false &&  vc.viewModel.hsn.value != nil && vc.viewModel.hsn.value?.isNotBlank ?? false && vc.viewModel.expectedDateOfDelivery.value != nil && vc.viewModel.expectedDateOfDelivery.value?.isNotBlank ?? false  {
                
                let quantity = vc.viewModel.quantity.value ?? ""
                let pricePerUnitPI = vc.viewModel.pricePerUnitPI.value ?? ""
                let hsn = vc.viewModel.hsn.value ?? ""
                
                if quantity.isValidNumber && Int(vc.viewModel.quantity.value!)! > 0 {
                    if pricePerUnitPI.isValidNumber && Int(vc.viewModel.pricePerUnitPI.value!)! > 0{
                        if hsn.isValidNumber {
                            if vc.isRevisedPI == true {
                                let parameters: [String: Any] = ["enquiryId":enquiryId,
                                                                 "cgst": 0,
                                                                 "expectedDateOfDelivery": vc.viewModel.expectedDateOfDelivery.value!,
                                                                 "hsn": Int(vc.viewModel.hsn.value!)!,
                                                                 "ppu": Int(vc.viewModel.pricePerUnitPI.value!)!,
                                                                 "quantity": Int(vc.viewModel.quantity.value!)!,
                                                                 "sgst": 0]
                                let request = OfflineOrderRequest.init(type: .sendRevisedPIRequest, orderId: vc.orderObject?.enquiryId ?? 0, changeRequestStatus: 0, changeRequestJson: parameters, submitRatingJson: nil)
                                OfflineRequestManager.defaultManager.queueRequest(request)
                            }else {
                                self.savePI(enquiryId: enquiryId, cgst: 0, expectedDateOfDelivery: vc.viewModel.expectedDateOfDelivery.value!, hsn: Int(hsn)!, ppu: Int(pricePerUnitPI)!, quantity: Int(quantity)!, sgst: 0).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                                        if json["valid"] as? Bool == true {
                                            DispatchQueue.main.async {
                                                print("PI saved successfully")
                                                vc.previewPI?(vc.viewModel.isOld.value!)
                                                
                                            }
                                        }
                                        else {
                                            vc.alert("Save PI failed, please try again later".localized)
                                            vc.hideLoading()
                                        }
                                    }
                                }.dispose(in: vc.bag)
                            }
                        }else {
                            vc.alert("Please enter valid hsn".localized)
                            vc.hideLoading()
                        }
                    }else {
                        vc.alert("Please enter valid price per unit".localized)
                        vc.hideLoading()
                    }
                }else {
                    vc.alert("Please enter valid quantity")
                    vc.hideLoading()
                }
            }else {
                vc.alert("Please enter all mandatory fields".localized)
                vc.hideLoading()
            }
        }
        
        vc.viewModel.sendFI = {
            if vc.viewModel.quantity.value != nil && vc.viewModel.quantity.value?.isNotBlank ?? false && vc.viewModel.pricePerUnitPI.value != nil && vc.viewModel.pricePerUnitPI.value?.isNotBlank ?? false &&  vc.viewModel.finalamount.value != nil && vc.viewModel.finalamount.value?.isNotBlank ?? false &&
                vc.viewModel.amountToBePaid.value != nil && vc.viewModel.amountToBePaid.value?.isNotBlank ?? false && vc.viewModel.cgst.value != nil && vc.viewModel.cgst.value?.isNotBlank ?? false &&
                vc.viewModel.sgst.value != nil && vc.viewModel.sgst.value?.isNotBlank ?? false && vc.viewModel.deliveryCharges.value != nil && vc.viewModel.deliveryCharges.value?.isNotBlank ?? false && vc.viewModel.advancePaidAmount.value != nil && vc.viewModel.advancePaidAmount.value?.isNotBlank ?? false && vc.viewModel.previousTotalAmount.value != nil && vc.viewModel.previousTotalAmount.value?.isNotBlank ?? false   {
                
                let quantity = vc.viewModel.quantity.value ?? ""
                let pricePerUnitPI = vc.viewModel.pricePerUnitPI.value ?? ""
                let finalamount = vc.viewModel.finalamount.value ?? ""
                let amountToBePaid = vc.viewModel.amountToBePaid.value ?? ""
                let cgst = vc.viewModel.cgst.value ?? ""
                let sgst = vc.viewModel.sgst.value ?? ""
                let deliveryCharges = vc.viewModel.deliveryCharges.value ?? ""
                let advancePaidAmount = vc.viewModel.advancePaidAmount.value ?? ""
                let previousTotalAmount = vc.viewModel.previousTotalAmount.value ?? ""
                let checkBox = vc.viewModel.checkBox.value
                
                if checkBox == 1{
                    if quantity.isValidNumber && Int(vc.viewModel.quantity.value!)! > 0 {
                        if pricePerUnitPI.isValidNumber && Int(vc.viewModel.pricePerUnitPI.value!)! > 0{
                            if previousTotalAmount.isValidNumber && Int(vc.viewModel.previousTotalAmount.value!)! > 0 {
                                if advancePaidAmount.isValidNumber{
                                    if cgst.isValidNumber {
                                        if sgst.isValidNumber {
                                            if finalamount.isValidNumber && Int(vc.viewModel.finalamount.value!)! > 0 {
                                                if amountToBePaid.isValidNumber {
                                                    if deliveryCharges.isValidNumber {
                                                        self.sendFinalInvoice(enquiryId: "\(vc.orderObject!.enquiryId)", advancePaidAmount: vc.viewModel.advancePaidAmount.value!, finalTotalAmount: Int(vc.viewModel.finalamount.value!)!, quantity: Int(vc.viewModel.quantity.value!)!, ppu: Int(vc.viewModel.pricePerUnitPI.value!)!, cgst: vc.viewModel.cgst.value!, sgst: vc.viewModel.sgst.value!, deliveryCharges: vc.viewModel.deliveryCharges.value!).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                                                            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                                                                if json["valid"] as? Bool == true {
                                                                    DispatchQueue.main.async {
                                                                        print("Final Invoice sent successfully")
                                                                        vc.hideLoading()
                                                                        vc.navigationController?.popViewController(animated: true)
                                                                        
                                                                    }
                                                                }
                                                                else {
                                                                    vc.alert("Sending final invoice failed, please try again later".localized)
                                                                    vc.hideLoading()
                                                                }
                                                            }
                                                        }.dispose(in: vc.bag)
                                                        
                                                    }else {
                                                        vc.alert("Please enter valid delivery charges".localized)
                                                        vc.hideLoading()
                                                    }
                                                }else {
                                                    vc.alert("Please enter valid amount to be paid".localized)
                                                    vc.hideLoading()
                                                }
                                            }else {
                                                vc.alert("Please enter valid final amount".localized)
                                                vc.hideLoading()
                                            }
                                        }else {
                                            vc.alert("Please enter valid SGST")
                                            vc.hideLoading()
                                        }
                                    }else {
                                        vc.alert("Please enter valid CGST")
                                        vc.hideLoading()
                                    }
                                    
                                }else {
                                    vc.alert("Please enter valid previous advance payment received".localized)
                                    vc.hideLoading()
                                }
                            }else {
                                vc.alert("Please enter valid previous total amount".localized)
                                vc.hideLoading()
                            }
                            
                            
                        }else {
                            vc.alert("Please enter valid price per unit".localized)
                            vc.hideLoading()
                        }
                    }else {
                        vc.alert("Please enter valid quantity".localized)
                        vc.hideLoading()
                    }
                    
                }else{
                    vc.alert("Please Agree to terms& conditions".localized)
                    vc.hideLoading()
                }
                
                
            }else {
                vc.alert("Please enter all mandatory fields".localized)
                vc.hideLoading()
            }
            
        }
        
        
        vc.previewPI = { (isOld) in
            vc.showLoading()
            self.getPreviewPI(enquiryId: enquiryId, isOld: isOld).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                DispatchQueue.main.async {
                    let object = String(data: responseData, encoding: .utf8) ?? ""
                    vc.view.showPreviewPIView(controller: vc, entityId: (vc.enquiryObject?.enquiryCode!)!, date: vc.viewModel.expectedDateOfDelivery.value!, data: object)
                    vc.hideLoading()
                }
            }.dispose(in: vc.bag)
        }
        
        vc.viewModel.downloadPI = {
            vc.showLoading()
            self.downloadAndSharePI(vc: vc, enquiryId: enquiryId)
        }
        
        vc.viewModel.sendPI = {
            self.sendPI(enquiryId: enquiryId, cgst: 0, expectedDateOfDelivery: vc.viewModel.expectedDateOfDelivery.value!, hsn: Int(vc.viewModel.hsn.value!)!, ppu: Int(vc.viewModel.pricePerUnitPI.value!)!, quantity: Int(vc.viewModel.quantity.value!)!, sgst: 0).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            print("PI sent successfully")
                            let client = try! SafeClient(wrapping: CraftExchangeClient())
                            if enquiryObj != nil {
                                let vc1 = EnquiryDetailsService(client: client).createEnquiryDetailScene(forEnquiry: enquiryObj, enquiryId: enquiryId) as! BuyerEnquiryDetailsController
                                vc1.modalPresentationStyle = .fullScreen
                                vc.hideLoading()
                                vc1.viewWillAppear?()
                                vc.popBack(toControllerType: BuyerEnquiryDetailsController.self)
                            }
                        }
                    }
                    else {
                        vc.alert("Send PI failed, please try again later".localized)
                        vc.hideLoading()
                    }
                }
            }.dispose(in: vc.bag)
        }
        return vc
    }
    
    func downloadAndSharePI(vc:UIViewController, enquiryId: Int) {
        self.downloadPI(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
            DispatchQueue.main.async {
                vc.hideLoading()
                if let url = try? Disk.saveAndURL(responseData, to: .caches, as: "\(enquiryId)/pdfFile.pdf") {
                    vc.sharePdf(path: url)
                }
            }
        }.dispose(in: vc.bag)
    }
}
