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

extension HomeScreenService {
    
  func createScene() -> UIViewController {
//    let profileStoryboard = UIStoryboard.init(name: "ArtisanTabbar", bundle: Bundle.main)
//    let vc = profileStoryboard.instantiateViewController(identifier: "ArtisanHomeController") as! ArtisanHomeController
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

            self.fetchAllArtisanProduct().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                print(responseData)
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                  if let array = json["data"] as? [[String: Any]] {
                      for obj in array {
                          if let prodArray = obj["products"] as? [[String: Any]] {
                            if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                                if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                                    DispatchQueue.main.async {
                                        object .forEach { (prodObj) in
                                            prodObj.saveOrUpdate()
                                            if prodObj == object.last {
                                                vc.dataSource = Product().getAllProductCatForUser()
                                                vc.refreshLayout()
                                            }
                                        }
//                                        vc.dataSource = Product().getAllProductCatForUser()
//                                        vc.viewWillLayoutSubviews()
                                    }
                                }
                            }
                          }
                      }
                  }
                }
            }.dispose(in: vc.bag)
            
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
            self.fetchAllArtisanProduct().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                print(responseData)
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                  if let array = json["data"] as? [[String: Any]] {
                      for obj in array {
                          if let prodArray = obj["products"] as? [[String: Any]] {
                            if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                                if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                                    DispatchQueue.main.async {
                                        object .forEach { (prodObj) in
                                            prodObj.saveOrUpdate()
                                            if prodObj == object.last {
                                                vc.dataSource = Product().getAllProductCatForUser()
                                                vc.refreshLayout()
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
                /*
                self.fetchAllProducts().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                    print(responseData)
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                      if let array = json["data"] as? [[String: Any]] {
                          for obj in array {
                              if let prodArray = obj["products"] as? [[String: Any]] {
                                if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                                    if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                                        DispatchQueue.main.async {
                                            object .forEach { (prodObj) in
                                                prodObj.saveOrUpdate()
                                            }
                                        }
                                    }
                                }
                              }
                          }
                      }
                    }
                }.dispose(in: vc.bag)*/

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
                
            }
        }
        return tab
      }
}