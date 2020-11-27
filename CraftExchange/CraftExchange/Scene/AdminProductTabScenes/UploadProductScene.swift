//
//  UploadProductScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 29/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension UploadProductService {
    func createScene(productObject: Product?) -> UIViewController {
        
        let vc = AdminUploadProductController.init(style: .plain)
        vc.product = productObject
        vc.viewModel.saveProductSelected = {
            if let prodName = vc.viewModel.prodName.value,
                let prodCode = vc.viewModel.prodCode.value,
                let productCategoryId = vc.viewModel.prodCategory.value?.entityID,
                let productTypeId = vc.viewModel.prodType.value?.entityID,
                let productSpec = vc.viewModel.prodDescription.value,
                let weight = vc.viewModel.prodWeight.value,
                let warpDyeId = vc.viewModel.warpDye.value?.entityID,
                let warpYarnCount = vc.viewModel.warpYarnCnt.value?.count ?? vc.viewModel.custWarpYarnCnt.value,
                let warpYarnId = vc.viewModel.warpYarn.value?.entityID,
                let weftDyeId = vc.viewModel.weftDye.value?.entityID,
                let weftYarnCount = vc.viewModel.weftYarnCnt.value?.count ?? vc.viewModel.custWeftYarnCnt.value,
                let weftYarnId = vc.viewModel.weftYarn.value?.entityID,
                let width = vc.viewModel.prodWidth.value,
                let length = vc.viewModel.prodLength.value,
                let reedCountId = vc.viewModel.reedCount.value?.entityID,
                productSpec.isNotBlank
            {
                let statusId = vc.viewModel.productAvailability.value == true ? 2 : 1
                let gsm = vc.viewModel.gsm.value ?? ""
                let weaveIds = vc.viewModel.prodWeaveType.value?.compactMap({$0.entityID})
                let careIds = vc.viewModel.prodCare.value?.compactMap({$0.entityID})
                let relatedProductId = vc.viewModel.prodType.value?.relatedProductTypes.first?.entityID
                let relatedProdLen = vc.viewModel.relatedProdLength.value
                let relatedProdWidth = vc.viewModel.relatedProdWidth.value
                let relatedProdWeight = vc.viewModel.relatedProdWeight.value
                let extraWeftDyeId = vc.viewModel.exWeftDye.value?.entityID
                let extraWeftYarnCount = vc.viewModel.exWeftYarnCnt.value?.count ?? vc.viewModel.custExWeftYarnCnt.value
                let extraWeftYarnId = vc.viewModel.exWeftYarn.value?.entityID
                
                var newProductObj = productDetails()
                newProductObj.tag = prodName
                newProductObj.code = prodCode
                newProductObj.productCategoryId = productCategoryId
                newProductObj.productTypeId = productTypeId
                newProductObj.productSpec = productSpec
                newProductObj.weight = weight
                newProductObj.warpDyeId = warpDyeId
                newProductObj.warpYarnId = warpYarnId
                newProductObj.warpYarnCount = warpYarnCount
                newProductObj.weftDyeId = weftDyeId
                newProductObj.weftYarnCount = weftYarnCount
                newProductObj.weftYarnId = weftYarnId
                newProductObj.extraWeftDyeId = extraWeftDyeId
                newProductObj.extraWeftYarnCount = extraWeftYarnCount
                newProductObj.extraWeftYarnId = extraWeftYarnId
                newProductObj.width = width
                newProductObj.length = length
                newProductObj.reedCountId = "\(reedCountId)"
                newProductObj.statusId = statusId
                newProductObj.gsm = gsm
                newProductObj.weaveIds = weaveIds
                newProductObj.careIds = careIds
                
                if relatedProductId != nil {
                    let newRelatedProd = relatedProductInfo.init(productTypeId: relatedProductId, width: relatedProdWidth, length: relatedProdLen, weigth: relatedProdWeight)
                    newProductObj.relatedProduct = [newRelatedProd]
                }
                
                var imgData: [(String,Data)] = []
                if vc.viewModel.productImages.value?.count ?? 0 > 0 {
                    var i = 1
                    vc.viewModel.productImages.value?.forEach({(obj) in
                        if let data = obj.pngData() {
                            imgData.append(("file\(i)",data))
                        } else if let data = obj.jpegData(compressionQuality: 1) {
                            imgData.append(("file\(i)",data))
                        }
                        i += 1
                    })
                }
                if let existingProduct = vc.product {
                    newProductObj.id = existingProduct.entityID
                    let request = OfflineProductRequest(type: .editProduct, imageData: imgData, json: newProductObj.editJSON(), artisanID: 0)
                    OfflineRequestManager.defaultManager.queueRequest(request)
                    //                    vc.navigationController?.popViewController(animated: true)
                    vc.popBack(toControllerType: ProductCatalogueController.self)
                }else {
                    //                    let request = OfflineProductRequest(type: .uploadProduct, imageData: imgData, json: newProductObj.toJSON(), artisanID: 0)
                    //                    OfflineRequestManager.defaultManager.queueRequest(request)
                    //                    vc.navigationController?.popViewController(animated: true)
                    //
                    let vc1 = self.createSelectArtisanScene(imageData: imgData, json: newProductObj.toJSON(), prodCat: vc.viewModel.prodCategory.value?.description  ?? "")
                    vc1.modalPresentationStyle = .fullScreen
                    vc.navigationController?.pushViewController(vc1, animated: true)
                    
                }
            }else {
                vc.alert("Error".localized, "Please enter all required data".localized) { (alert) in
                    
                }
            }
        }
        
        vc.viewModel.deleteProductSelected = {
            self.deleteArtisanProduct(withId: productObject?.entityID ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,response) in
                DispatchQueue.main.async {
                    Product.productIsDeleteTrue(forId: productObject?.entityID ?? 0)
                    CatalogueProduct.productIsDeleteTrue(forId: productObject?.entityID ?? 0)
//                    vc.navigationController?.popViewController(animated: true)
                    vc.popBack(toControllerType: ProductCatalogueController.self)
                }
            }.dispose(in: vc.bag)
        }
        
        return vc
    }
    
    func createCustomProductScene(productObject: CustomProduct?) -> UIViewController {
        
        let vc = UploadCustomProductController.init(style: .plain)
        vc.product = productObject
        
        vc.viewWillAppear = {
            vc.showLoading()
            self.getCustomProductDetails(prodId: productObject?.entityID ?? 0, vc: vc)
        }
        
        vc.viewModel.saveProductSelected = {
            if let productCategoryId = vc.viewModel.prodCategory.value?.entityID,
                let productTypeId = vc.viewModel.prodType.value?.entityID,
                let productSpec = vc.viewModel.prodDescription.value,
                let warpDyeId = vc.viewModel.warpDye.value?.entityID,
                let warpYarnCount = vc.viewModel.warpYarnCnt.value?.count ?? vc.viewModel.custWarpYarnCnt.value,
                let warpYarnId = vc.viewModel.warpYarn.value?.entityID,
                let weftDyeId = vc.viewModel.weftDye.value?.entityID,
                let weftYarnCount = vc.viewModel.weftYarnCnt.value?.count ?? vc.viewModel.custWeftYarnCnt.value,
                let weftYarnId = vc.viewModel.weftYarn.value?.entityID,
                let width = vc.viewModel.prodWidth.value,
                let length = vc.viewModel.prodLength.value,
                let reedCountId = vc.viewModel.reedCount.value?.entityID,
                productSpec.isNotBlank
            {
                let gsm = vc.viewModel.gsm.value ?? ""
                let weaveIds = vc.viewModel.prodWeaveType.value?.compactMap({$0.entityID})
                let relatedProductId = vc.viewModel.prodType.value?.relatedProductTypes.first?.entityID
                let relatedProdLen = vc.viewModel.relatedProdLength.value
                let relatedProdWidth = vc.viewModel.relatedProdWidth.value
                let extraWeftDyeId = vc.viewModel.exWeftDye.value?.entityID
                let extraWeftYarnCount = vc.viewModel.exWeftYarnCnt.value?.count ?? vc.viewModel.custExWeftYarnCnt.value
                let extraWeftYarnId = vc.viewModel.exWeftYarn.value?.entityID
                
                var newProductObj = productDetails()
                newProductObj.productCategoryId = productCategoryId
                newProductObj.productTypeId = productTypeId
                newProductObj.productSpec = productSpec
                newProductObj.warpDyeId = warpDyeId
                newProductObj.warpYarnId = warpYarnId
                newProductObj.warpYarnCount = warpYarnCount
                newProductObj.weftDyeId = weftDyeId
                newProductObj.weftYarnCount = weftYarnCount
                newProductObj.weftYarnId = weftYarnId
                newProductObj.extraWeftDyeId = extraWeftDyeId
                newProductObj.extraWeftYarnCount = extraWeftYarnCount
                newProductObj.extraWeftYarnId = extraWeftYarnId
                newProductObj.width = width
                newProductObj.length = length
                newProductObj.reedCountId = "\(reedCountId)"
                newProductObj.gsm = gsm
                newProductObj.weaveIds = weaveIds
                
                if relatedProductId != nil {
                    let newRelatedProd = relatedProductInfo.init(productTypeId: relatedProductId, width: relatedProdWidth, length: relatedProdLen, weigth: nil)
                    newProductObj.relatedProduct = [newRelatedProd]
                }
                
                var imgData: [(String,Data)] = []
                if vc.viewModel.productImages.value?.count ?? 0 > 0 {
                    var i = 1
                    vc.viewModel.productImages.value?.forEach({(obj) in
                        if let data = obj.pngData() {
                            imgData.append(("file\(i)",data))
                        } else if let data = obj.jpegData(compressionQuality: 1) {
                            imgData.append(("file\(i)",data))
                        }
                        i += 1
                    })
                }
                if let existingProduct = vc.product {
                    vc.showLoading()
                    newProductObj.id = existingProduct.entityID
                    let request = OfflineProductRequest(type: .editCustomProd, imageData: imgData, json: newProductObj.editJSON(), artisanID: 0)
                    OfflineRequestManager.defaultManager.queueRequest(request)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        vc.hideLoading()
                        vc.navigationController?.popViewController(animated: true)
                    }
                }else {
                    let request = OfflineProductRequest(type: .uploadCustomProd, imageData: imgData, json: newProductObj.toJSON(), artisanID: 0)
                    OfflineRequestManager.defaultManager.queueRequest(request)
                    vc.navigationController?.popViewController(animated: true)
                }
            }else {
                vc.alert("Error".localized, "Please enter all required data".localized) { (alert) in
                    
                }
            }
        }
        
        vc.viewModel.deleteProductSelected = {
            self.deleteBuyerCustomProduct(withId: productObject?.entityID ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,response) in
                DispatchQueue.main.async {
                    vc.navigationController?.popViewController(animated: true)
                }
            }.dispose(in: vc.bag)
        }
        
        return vc
    }
    
    func getCustomProductDetails(prodId: Int, vc: UIViewController) {
        self.getCustomProductDetails(withId: prodId).bind(to: vc, context: .global(qos: .userInteractive)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let prodDict = json["data"] as? [String: Any] {
                        if let prodDictionary = prodDict["buyerCustomProduct"] as? [String: Any] {
                            if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                                if let object = try? JSONDecoder().decode(CustomProduct.self, from: proddata) {
                                    DispatchQueue.main.async {
                                        object.saveOrUpdate()
                                        vc.hideLoading()
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
    
    func createSelectArtisanScene(imageData: [(String,Data)]?, json: [String: Any], prodCat: String?) -> UIViewController {
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectArtisanController") as! SelectArtisanController
        //  vc.productCategoryLabel.text = prodCat ?? ""
        func performSync(){
            self.getFilteredAllArtisans().toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let artisanarray = json["data"] as? [[String: Any]] {
                        var i = 0
                        artisanarray.forEach { (dataDict) in
                            i += 1
                            if let artisandata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                                if let productObj = try? JSONDecoder().decode(SelectArtisanBrand.self, from: artisandata) {
                                    DispatchQueue.main.async {
                                        print("productObj: \(productObj)")
                                        productObj.saveOrUpdate()
                                        
                                        if i == artisanarray.count {
                                            vc.endRefresh()
                                            
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                }else {
                    vc.endRefresh()
                }
            }.dispose(in: vc.bag)
            
            vc.hideLoading()
        }
        
        func syncData() {
            guard !vc.isEditing else { return }
            guard vc.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    vc.endRefresh()
                }
                return
            }
            performSync()
        }
        
        vc.viewWillAppear = {
            syncData()
        }
        
        vc.saveProductSelected = { (artisanID) in
            let request = OfflineProductRequest(type: .uploadProduct, imageData: imageData, json: json, artisanID: artisanID)
            OfflineRequestManager.defaultManager.queueRequest(request)
            //            vc.navigationController?.popViewController(animated: true)
//            vc.popBack(toControllerType: ProductCatalogueController.self)
//            let viewControllers = vc.navigationController!.viewControllers
//            if viewControllers.count >= 2 {
//                vc.navigationController!.viewControllers.remove(at: viewControllers.count - 2)
//            }
            vc.navigationController?.popToRootViewController(animated: true)
        }
        
        return vc
    }
}
