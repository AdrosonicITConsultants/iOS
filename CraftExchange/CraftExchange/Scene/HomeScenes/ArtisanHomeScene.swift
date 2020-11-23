//
//  ArtisanHomeScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit
/*
extension HomeScreenService {

  func createScene() -> UIViewController {
    let storyboard = UIStoryboard(name: "ArtisanTabbar", bundle: nil)
    let tab = storyboard.instantiateViewController(withIdentifier: "ArtisanTabbarController") as! ArtisanTabbarController
    tab.modalPresentationStyle = .fullScreen
    let nav = tab.customizableViewControllers?.first as! UINavigationController
    let vc = nav.topViewController as! ArtisanHomeController
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString")
    }.dispose(in: vc.bag)
    
    vc.viewModel.viewDidLoad = {
        if vc.reachabilityManager?.connection != .unavailable {
//            vc.showLoading()
            self.fetchCategoryData(vc: vc)
            self.fetchCountryData(vc: vc)
            self.fetchClusterData(vc: vc)
            self.fetchProductUploadData(vc: vc)
            self.fetchEnquiryStateData(vc: vc)
            self.fetchNotification(vc: vc)
            self.handlePushNotification(vc: vc)
            self.fetchTransactionStatus(vc: vc)
            
            self.fetch().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
              DispatchQueue.main.async {
                vc.hideLoading()
              }
                do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                if let dataDict = jsonDict["data"] as? Dictionary<String,Any> {
                print("logged In User: \(jsonDict)")
                guard let userObj = dataDict["user"] as? Dictionary<String,Any> else {
                    DispatchQueue.main.async {
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Products".localized)")
                    }
                    return
                }
                let userData = try JSONSerialization.data(withJSONObject: userObj, options: .prettyPrinted)
                let loggedInUser = try? JSONDecoder().decode(User.self, from: userData)
                loggedInUser?.saveOrUpdate()
                loggedInUser?.addressList .forEach({ (addr) in
                    addr.saveOrUpdate()
                })
                loggedInUser?.paymentAccountList .forEach({ (addr) in
                    addr.saveOrUpdate()
                })
                if let categoryData = dataDict["userProductCategories"] as? [[String:Any]] {
                    let catData = try JSONSerialization.data(withJSONObject: categoryData, options: .prettyPrinted)
                    if let userCategories = try? JSONDecoder().decode([UserProductCategory].self, from: catData) {
                        loggedInUser?.saveOrUpdateUserCategory(catArr: userCategories)
                    }
                }
                DispatchQueue.main.async {
                    vc.loggedInUserName.text = User.loggedIn()?.firstName ?? ""
                }
                }else {
                DispatchQueue.main.async {
                    vc.hideLoading()
                    vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Profile".localized)")
                }
                }
                } else {
                DispatchQueue.main.async {
                    vc.hideLoading()
                    vc.alert("Unable to update Profile".localized)
                }
                }
                } catch let error as NSError {
                DispatchQueue.main.async {
                    vc.hideLoading()
                    vc.alert("\(error.description)")
                }
                }
            }.dispose(in: vc.bag)
            }
        
        vc.viewModel.viewWillAppear = {
            guard vc.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    vc.dataSource = Product().getAllProductCatForUser()
                    vc.refreshLayout()
                }
                return
            }
            Product.setAllArtisanProductIsDeleteTrue()
//            vc.dataSource = Product().getAllProductCatForUser()
//            vc.refreshLayout()
            self.fetchAllArtisanProduct().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                print(responseData)
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                  if let array = json["data"] as? [[String: Any]] {
                      for obj in array {
                          if let prodArray = obj["products"] as? [[String: Any]] {
                            if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                                if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                                    DispatchQueue.main.async {
//                                        Product.setAllArtisanProductIsDeleteTrue()
                                        object .forEach { (prodObj) in
                                            prodObj.saveOrUpdate()
                                            if prodObj == object.last {
                                                vc.dataSource = Product().getAllProductCatForUser()
                                                vc.refreshLayout()
                                                Product.deleteAllArtisanProductsWithIsDeleteTrue()
                                            }
                                        }
                                    }
                                }
                            }
                          }
                      }
                  }else {
                    Product.setAllArtisanProductIsDeleteFalse()
                    vc.dataSource = Product().getAllProductCatForUser()
                    vc.refreshLayout()
                }
                }else {
                    Product.setAllArtisanProductIsDeleteFalse()
                    vc.dataSource = Product().getAllProductCatForUser()
                    vc.refreshLayout()
                }
            }.dispose(in: vc.bag)
        }
    }
    return tab
  }

    func fetchNotification(vc: UIViewController) {
        let service = NotificationService.init(client: client)
        service.getAllTheNotifications().bind(to: vc, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let dataDict = json["data"] as? Dictionary<String,Any>
                    {
                        guard let notiObj = dataDict["getAllNotifications"] as? [[String: Any]] else {
                            return
                        }
                        if let notidata = try? JSONSerialization.data(withJSONObject: notiObj, options: .fragmentsAllowed) {
                            if  let notiBuyer = try? JSONDecoder().decode([Notifications].self, from: notidata) {
                                DispatchQueue.main.async {
                                    if let lbl = vc.navigationController?.view.viewWithTag(666) as? UILabel {
                                        lbl.text = "\(notiBuyer.count)"
                                        UIApplication.shared.applicationIconBadgeNumber = notiBuyer.count
                                    }
                                }
                            }
                        }
                    }
                }
        }.dispose(in: vc.bag)
    }

    func createBuyerScene() -> UIViewController {

        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let tab = storyboard.instantiateViewController(withIdentifier: "BuyerTabbarController") as! BuyerTabbarController
        tab.modalPresentationStyle = .fullScreen
        let nav = tab.customizableViewControllers?.first as! UINavigationController
        let vc = nav.topViewController as! BuyerHomeController
        
        self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
            print("responseString")
        }.dispose(in: vc.bag)
        
        vc.viewModel.viewDidLoad = {
            if vc.reachabilityManager?.connection != .unavailable {
    //            vc.showLoading()
                
                self.fetchCategoryData(vc: vc)
                self.fetchCountryData(vc: vc)
                self.fetchClusterData(vc: vc)
                self.fetchProductUploadData(vc: vc)
                self.fetchEnquiryStateData(vc: vc)
                self.fetchNotification(vc: vc)
                self.handlePushNotification(vc: vc)
                self.fetchTransactionStatus(vc: vc)
                
                self.fetch().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                  DispatchQueue.main.async {
                    vc.hideLoading()
                  }
                    do {
                    if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                    {
                    if let dataDict = jsonDict["data"] as? Dictionary<String,Any> {
                    print("logged In User: \(jsonDict)")
                    guard let userObj = dataDict["user"] as? Dictionary<String,Any> else {
                        DispatchQueue.main.async {
                            vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Products".localized)")
                        }
                        return
                    }
                    let userData = try JSONSerialization.data(withJSONObject: userObj, options: .prettyPrinted)
                    let loggedInUser = try? JSONDecoder().decode(User.self, from: userData)
                    loggedInUser?.saveOrUpdate()
                    loggedInUser?.addressList .forEach({ (addr) in
                        addr.saveOrUpdate()
                    })
                    loggedInUser?.paymentAccountList .forEach({ (addr) in
                        addr.saveOrUpdate()
                    })
                    DispatchQueue.main.async {
                        vc.loggedInUserName.text = User.loggedIn()?.firstName ?? ""
                    }
                    }else {
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Profile".localized)")
                    }
                    }
                    } else {
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        vc.alert("Unable to update Profile".localized)
                    }
                    }
                    } catch let error as NSError {
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        vc.alert("\(error.description)")
                    }
                    }
                }.dispose(in: vc.bag)
                }
            
            vc.viewModel.viewWillAppear = {
                let service = WishlistService.init(client: self.client)
                service.fetchAllWishlistProducts().observeNext { (attachment) in
                    if let json = try? JSONSerialization.jsonObject(with: attachment, options: .allowFragments) as? [String: Any] {
                      if let array = json["data"] as? [[String: Any]] {
                        var finalArray: [Int] = []
                        array.forEach { (dataDict) in
                            if let prodDict = dataDict["product"] as? [String: Any] {
                                if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                                    if let prodObj = try? JSONDecoder().decode(Product.self, from: proddata) {
                                        DispatchQueue.main.async {
                                            prodObj.saveOrUpdate()
                                            finalArray.append(prodObj.entityID)
                                            if finalArray.count == array.count {
                                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                                    appDelegate.wishlistIds = finalArray
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                      }
                    }
                }.dispose(in: vc.bag)
            }
        }
        return tab
      }
}*/
