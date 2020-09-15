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
        
        vc.viewWillAppear = {
            vc.showLoading()
            self.getOpenEnquiryDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
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
                                    vc.reloadFormData()
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
                DispatchQueue.main.async {
                    vc.hideLoading()
                }
            }.dispose(in: vc.bag)
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
        
        return vc
    }
}

