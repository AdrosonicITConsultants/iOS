//
//  BuyerProductDetailsScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension ProductCatalogService {
    func createProdDetailScene(forProduct: Product?) -> UIViewController {
        let vc = BuyerProductDetailController.init(style: .plain)
        vc.product = forProduct
        
        vc.viewWillAppear = {
            vc.showLoading()
            self.getProductDetails(prodId: forProduct?.entityID ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let prodDictionary = json["data"] as? [String: Any] {
                            if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                                if let object = try? JSONDecoder().decode(Product.self, from: proddata) {
                                    DispatchQueue.main.async {
                                        object.saveOrUpdate()
                                        vc.hideLoading()
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
        
        vc.addProdDetailToWishlist = { (prodId) in
//            let service = ProductCatalogService.init(client: self.client)
            self.addProductToWishlist(prodId: prodId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            appDelegate?.wishlistIds?.append(prodId)
                            let row = vc.form.rowBy(tag: "ProductNameRow")
                            row?.updateCell()
                        }
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.deleteProdDetailToWishlist = { (prodId) in
//            let service = ProductCatalogService.init(client: self.client)
            self.removeProductFromWishlist(prodId: prodId).observeNext { (attachment) in
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    if let index = appDelegate?.wishlistIds?.firstIndex(where: { (obj) -> Bool in
                        obj == prodId
                    }) {
                        appDelegate?.wishlistIds?.remove(at: index)
                    }
                    let row = vc.form.rowBy(tag: "ProductNameRow")
                    row?.updateCell()
                }
            }.dispose(in: vc.bag)
        }
        
        return vc
    }
}