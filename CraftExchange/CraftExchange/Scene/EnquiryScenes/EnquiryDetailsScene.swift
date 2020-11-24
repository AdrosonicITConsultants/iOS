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
    
    func createEnquiryDetailScene(forEnquiry: AdminEnquiry?, enquiryId: Int) -> UIViewController {
        let vc = BuyerEnquiryDetailsController.init(style: .plain)
        vc.enquiryObject = forEnquiry
        
        vc.viewWillAppear = {
            /*vc.showLoading()
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
            }.dispose(in: vc.bag)*/
        }
        
        vc.showCustomProduct = {
            vc.showLoading()
            let service = UploadProductService.init(client: self.client)
            service.getCustomProductDetails(prodId: forEnquiry?.customProductId ?? 0, vc: vc)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                vc.hideLoading()
                let realm = try? Realm()
                if let object = realm?.objects(CustomProduct.self).filter("%K == %@", "entityID", forEnquiry?.customProductId ?? 0).first {
                    let newVC = ProductCatalogService(client: self.client).createAdminCustomProductDetailScene(forProduct: forEnquiry?.customProductId ?? 0)
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
            service.showSelectedHistoryProduct(for: vc, prodId: forEnquiry?.productHistoryId ?? 0)
            vc.hideLoading()
        }
        
        vc.closeEnquiry = { (enquiryId) in
            self.closeEnquiry(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                DispatchQueue.main.async {
                    vc.navigationController?.popViewController(animated: true)
                }
            }
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
        
        vc.viewPI = {
            self.getPreviewPI(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                DispatchQueue.main.async {
                    let object = String(data: responseData, encoding: .utf8) ?? ""
                    if let date = vc.enquiryObject?.lastUpdated {
                        let dateStr = date.ttceISOString(isoDate: date)
                        vc.view.showAcceptedPIView(controller: vc, entityId: (vc.enquiryObject?.code!)!, date: dateStr , data: object)
                    }
                    vc.hideLoading()
                }
            }.dispose(in: vc.bag)
        }
        
        vc.downloadPI = {
            self.downloadAndSharePI(vc: vc, enquiryId: enquiryId)
        }
        
        vc.getPI = {
            self.getPI(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let dataDict = json["data"] as? Dictionary<String,Any>
                    {
                        if let moqdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                            if  let object = try? JSONDecoder().decode(GetPI.self, from: moqdata) {
                                DispatchQueue.main.async {
                                    vc.PI = object
                                    print("hey: \(object)")
                                }
                            }
                        }
                    }
                }
            }.dispose(in: vc.bag)
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

