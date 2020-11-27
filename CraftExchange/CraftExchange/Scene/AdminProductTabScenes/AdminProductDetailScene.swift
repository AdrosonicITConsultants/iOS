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
    func createAdminProductDetailScene(forProductId: Int?, isCustom: Bool, isRedirect: Bool, enquiryCode: String?, buyerBrand: String?, enquiryDate: String?, enquiryId: Int?) -> UIViewController {
        let vc = AdminProductDetailController.init(style: .plain)
        vc.isRedirect = isRedirect
        if isCustom {
            vc.customProduct = CustomProduct.getCustomProduct(searchId: forProductId ?? 0)
            vc.isCustom = isCustom
            vc.enquiryDate = enquiryDate
            vc.enquiryCode = enquiryCode
            vc.buyerBrand = buyerBrand
            vc.enquiryId = enquiryId
        }else{
            vc.product = Product.getProduct(searchId: forProductId ?? 0)
            vc.isCustom = isCustom
        }
        
        
        vc.viewWillAppear = {
            vc.showLoading()
            if isCustom {
                self.getCustomProductDetails(withId: forProductId ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            if let dataDictionary = json["data"] as? [String: Any] {
                                if let prodDictionary = dataDictionary["buyerCustomProduct"] as? [String: Any] {
                                    if let proddata = try? JSONSerialization.data(withJSONObject: prodDictionary, options: .fragmentsAllowed) {
                                        if let object = try? JSONDecoder().decode(CustomProduct.self, from: proddata) {
                                            DispatchQueue.main.async {
                                                print(object)
                                                object.saveOrUpdate()
                                                vc.customProduct = object
                                                vc.form.allRows.forEach { (row) in
                                                    row.updateCell()
                                                    row.reload()
                                                }
                                                if let section1 = vc.form.sectionBy(tag: "weave section") {
                                                    if section1.isEmpty == true {
                                                        vc.weavesFunc()
                                                    }
                                                }
                                               
                                                vc.tableView?.reloadData()
                                                vc.hideLoading()
                                            }
                                        }
                                    }
                                }
                            }
                        }else {
                            self.getCustomProductDetails2(withId: forProductId ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                                    if json["valid"] as? Bool == true {
                                        if let dataDictionary = json["data"] as? [String: Any] {
                                            
                                            if let proddata = try? JSONSerialization.data(withJSONObject: dataDictionary, options: .fragmentsAllowed) {
                                                if let object = try? JSONDecoder().decode(CustomProduct.self, from: proddata) {
                                                    DispatchQueue.main.async {
                                                        print(object)
                                                        object.saveOrUpdate()
                                                        vc.customProduct = object
                                                        vc.form.allRows.forEach { (row) in
                                                            row.updateCell()
                                                            row.reload()
                                                        }
                                                        if let section1 = vc.form.sectionBy(tag: "weave section") {
                                                            if section1.isEmpty == true {
                                                                vc.weavesFunc()
                                                            }
                                                        }
                                                        
                                                        vc.hideLoading()
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }else {
                                        
                                    }
                                }
                                DispatchQueue.main.async {
                                    vc.hideLoading()
                                }
                            }.dispose(in: vc.bag)
                        }
                    }
                    DispatchQueue.main.async {
                        vc.hideLoading()
                    }
                }.dispose(in: vc.bag)
            }else{
                self.getProductDetails(prodId: forProductId ?? 0).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
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
                                                if let section1 = vc.form.sectionBy(tag: "weave section") {
                                                    if section1.isEmpty == true {
                                                        vc.weavesFunc()
                                                    }
                                                }
                                                if let section2 = vc.form.sectionBy(tag: "wash section") {
                                                    if section2.isEmpty == true {
                                                        vc.washFunc()
                                                    }
                                                }
                                            
                                                vc.tableView?.reloadData()
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
            
            vc.hideLoading()
        }
        
        return vc
    }
    
    func createAdminProductDetailScene(forProduct: Int, isEdit: Bool) -> UIViewController {
        let vc = AdminProductDetailController.init(style: .plain)
        //  vc.product = forProduct
        
        vc.product = Product.getProduct(searchId: forProduct)
        vc.isEdit = isEdit
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
                                            if let section1 = vc.form.sectionBy(tag: "weave section") {
                                                if section1.isEmpty == true {
                                                    vc.weavesFunc()
                                                }
                                            }
                                            if let section2 = vc.form.sectionBy(tag: "wash section") {
                                                if section2.isEmpty == true {
                                                    vc.washFunc()
                                                }
                                            }
                                            vc.tableView?.reloadData()
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
    
}

