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
    func createScene() -> UIViewController {
    
        let vc = UploadProductController.init(style: .plain)
        
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
                let reedCountId = vc.viewModel.reedCount.value?.entityID
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
                
                let request = OfflineProductRequest(type: .uploadProduct, imageData: imgData, json: newProductObj.toJSON())
                OfflineRequestManager.defaultManager.queueRequest(request)
                vc.navigationController?.popViewController(animated: true)
            }else {
                vc.alert("Error".localized, "Please enter all required data".localized) { (alert) in
                    
                }
            }
        }
        
        return vc
    }
}
