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
    func piCreate(enquiryId: Int) -> UIViewController {
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
                            
                                    self.savePI(enquiryId: enquiryId, cgst: 0, expectedDateOfDelivery: vc.viewModel.expectedDateOfDelivery.value!, hsn: Int(hsn)!, ppu: Int(pricePerUnitPI)!, quantity: Int(quantity)!, sgst: 0).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                                            if json["valid"] as? Bool == true {
                                                DispatchQueue.main.async {
                                          print("PI saved successfully")
                                                    vc.previewPI?()
                                                  
                                                }
                                            }
                                            else {
                                                vc.alert("Save PI failed, please try again later")
                                                vc.hideLoading()
                                            }
                                        }
                                    }.dispose(in: vc.bag)
                               
                        }else {
                            vc.alert("Please enter valid hsn")
                            vc.hideLoading()
                        }
                    }else {
                        vc.alert("Please enter valid price per unit")
                        vc.hideLoading()
                    }
                }else {
                    vc.alert("Please enter valid quantity")
                    vc.hideLoading()
                }
            }else {
                vc.alert("Please enter all mandatory fields")
                vc.hideLoading()
            }
        }
        
        vc.previewPI = {
            vc.showLoading()
            self.getPreviewPI(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
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
                                       let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "BuyerEnquiryListController") as! BuyerEnquiryListController
                                vc.hideLoading()
                                controller.viewWillAppear?()
                                vc.popBack(toControllerType: BuyerEnquiryListController.self)
                               }
                           }
                           else {
                               vc.alert("Send PI failed, please try again later")
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
