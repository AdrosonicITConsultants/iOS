//
//  AdminHomeScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension AdminHomeScreenService {
    func createScene() -> UIViewController {
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let tab = storyboard.instantiateViewController(withIdentifier: "MarketingTabbarController") as! MarketingTabbarController
        tab.modalPresentationStyle = .fullScreen
        let nav = tab.customizableViewControllers?.first as! UINavigationController
        let vc = nav.topViewController as! MarketHomeController
        
        self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
            print("responseString")
        }.dispose(in: vc.bag)
        
        vc.viewWillAppear = {
            if vc.reachabilityManager?.connection != .unavailable {
                self.getEnquiryAndOrderCount(vc: vc)
                self.fetchCategoryData(vc: vc)
                self.fetchCountryData(vc: vc)
                self.fetchClusterData(vc: vc)
                self.fetchProductUploadData(vc: vc)
                self.fetchEnquiryStateData(vc: vc)
                self.handlePushNotification(vc: vc)
                self.fetchTransactionStatus(vc: vc)
            }
        }
        return tab
      }
    
    func getEnquiryAndOrderCount(vc: UIViewController){
        self.fetchAllAdminEnquiryAndOrder().bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let dataArray = json["data"] as? [[String: Any]] {
                        if let chatdata = try? JSONSerialization.data(withJSONObject: dataArray, options: .fragmentsAllowed) {
                            if  let chatObj = try? JSONDecoder().decode([MarketingCount].self, from: chatdata) {
                                DispatchQueue.main.async {
                                    for chat in chatObj {
                                        print(chat)
                                        let app = UIApplication.shared.delegate as? AppDelegate
                                        app?.countData = chat
//                                        let row = MarketHomeController().form.rowBy(tag: "HorizonatalAdmin1")
//                                        row?.updateCell()
//                                        row?.reload()
                                        if let controller = vc as? MarketHomeController {
                                            controller.refreshCountForTag()
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
    
    func fetchClusterData(vc: UIViewController) {
        self.fetchAllClusters().bind(to: vc, context: .global(qos: .background)) { (_, clusterArray) in
            do {
                if (clusterArray.count > 0) {
                    clusterArray.forEach( {clusterObj in
                      clusterObj.saveOrUpdate()
                    }
                  )
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchCountryData(vc: UIViewController) {
        self.fetchAllCountries().bind(to: vc, context: .global(qos: .background)) { (_, countryArray) in
            do {
                if (countryArray.count > 0) {
                    countryArray.forEach( {countryObj in
                      countryObj.saveOrUpdate()
                    }
                  )
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchCategoryData(vc: UIViewController) {
        self.fetchAllProductCategory().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([ProductCategory].self, from: data) .forEach({ (cat) in
                            cat.saveOrUpdate()
                        })
                  }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchTransactionStatus(vc: UIViewController) {
        let service = TransactionService.init(client: client)
        service.getTransactionStatus().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([TransactionStatus].self, from: data) .forEach({ (cat) in
                            cat.saveOrUpdate()
                        })
                  }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchProductUploadData(vc: UIViewController) {
        self.fetchProductUploadData().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let dataDictionary = json["data"] as? [String: Any] {
                        if let prodCatArray = dataDictionary["productCategories"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: prodCatArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ProductCategory].self, from: data) .forEach({ (cat) in
                                cat.saveOrUpdate()
                            })
                        }
                        if let weavesArray = dataDictionary["weaves"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: weavesArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([Weave].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let yarnsArray = dataDictionary["yarns"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: yarnsArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([Yarn].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let reedsArray = dataDictionary["reedCounts"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: reedsArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ReedCount].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let dyesArray = dataDictionary["dyes"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: dyesArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([Dye].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let prodCareArray = dataDictionary["productCare"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: prodCareArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ProductCare].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                  }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func handlePushNotification(vc: UIViewController) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.requestPushNotificationAccess()
        if let object = delegate?.notificationObject {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowNotification"), object: object)
        }
    }
    
    func fetchEnquiryStateData(vc: UIViewController) {
        let service = EnquiryListService.init(client: client)
        service.getEnquiryStages().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([EnquiryStages].self, from: data) .forEach({ (stage) in
                            stage.saveOrUpdate()
                        })
                  }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
}
