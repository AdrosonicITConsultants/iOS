//
//  AdminProductDetailScene.swift
//  CraftExchange
//
//  Created by Kalyan on 21/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Realm
import RealmSwift

extension ProductCatalogService {
    func createAdminProductDetailScene(forProduct: CatalogueProduct?) -> UIViewController {
        let vc = AdminProductDetailController.init(style: .plain)
        //  vc.product = forProduct
        
        vc.product = Product.getProduct(searchId: forProduct?.entityID ?? 0)
        
        vc.viewWillAppear = {
            vc.showLoading()
            self.getProductDetails(prodId: forProduct?.entityID ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let dataDictionary = json["data"] as? [String: Any] {
                            if let prodDictionary = dataDictionary["product"] as? [String: Any] {
                                if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                                    if let object = try? JSONDecoder().decode(Product.self, from: proddata) {
                                        DispatchQueue.main.async {
                                            print(object)
                                            object.saveOrUpdate()
                                            vc.product = object
                                            vc.form.allRows.forEach { (row) in
                                                row.updateCell()
                                                row.reload()
                                            }
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
            vc.hideLoading()
        }
        
        return vc
    }
    
    func createAdminProductDetailScene(forProduct: Int) -> UIViewController {
        let vc = AdminProductDetailController.init(style: .plain)
        //  vc.product = forProduct
        
        vc.product = Product.getProduct(searchId: forProduct)
        
        vc.viewWillAppear = {
            vc.showLoading()
            self.getProductDetails(prodId: forProduct).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let dataDictionary = json["data"] as? [String: Any] {
                            if let prodDictionary = dataDictionary["product"] as? [String: Any] {
                                if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                                    if let object = try? JSONDecoder().decode(Product.self, from: proddata) {
                                        DispatchQueue.main.async {
                                            print(object)
                                            object.saveOrUpdate()
                                            vc.product = object
                                            vc.form.allRows.forEach { (row) in
                                                row.updateCell()
                                                row.reload()
                                            }
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
            vc.hideLoading()
        }
        
        return vc
    }
    
    func createAdminCustomProductDetailScene(forProduct: Int) -> UIViewController {
        let vc = AdminProductDetailController.init(style: .plain)
        //  vc.product = forProduct
        
        vc.viewWillAppear = {
            vc.showLoading()
            let service = UploadProductService.init(client: self.client)
            service.getCustomProductDetails(prodId: forProduct, vc: vc)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                vc.hideLoading()
                let realm = try? Realm()
                if let object = realm?.objects(CustomProduct.self).filter("%K == %@", "entityID", forProduct).first {
                    vc.customProduct = object
                    vc.form.allRows.forEach { (row) in
                        row.updateCell()
                        row.reload()
                    }
                    vc.hideLoading()
                }
            }
            vc.hideLoading()
        }
        
        return vc
    }
}
