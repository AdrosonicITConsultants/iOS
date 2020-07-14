//
//  MyProfileScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension MyProfileService {
    
  func createScene() -> UIViewController {
    let profileStoryboard = UIStoryboard.init(name: "MyProfile", bundle: Bundle.main)
    let vc = profileStoryboard.instantiateViewController(identifier: "BuyerProfileController") as! BuyerProfileController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString")
    }.dispose(in: vc.bag)
    
    vc.viewModel.updateArtisanProfile = { json in
        self.updateArtisanProfile(json: json).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool ?? false {
                        DispatchQueue.main.async {
                            vc.alert("Success", "\(json["data"] as? String ?? "Profile updated successfully".localized)") { (action) in
                            }
                        }
                  }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    vc.viewModel.updateArtisanBrandDetails = { json in
        self.updateArtisanBrand(json: json).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool ?? false {
                        DispatchQueue.main.async {
                            vc.alert("Success", "\(json["data"] as? String ?? "Artisan Brand Details updated successfully".localized)") { (action) in
                            }
                        }
                  }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    vc.viewModel.updateArtisanBankDetails = { json in
        self.updateArtisanBank(json: json).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool ?? false {
                        DispatchQueue.main.async {
                            vc.alert("Success", "\(json["data"] as? String ?? "Artisan Brand Details updated successfully".localized)") { (action) in
                            }
                        }
                  }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    vc.viewModel.updateBuyerDetails = { (json, data, filename) in
        self.updateBuyerDetails(json: json, imageData: data, filename: filename).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool ?? false {
                        DispatchQueue.main.async {
                            vc.alert("Success", "\(json["data"] as? String ?? "Buyer Details updated successfully".localized)") { (action) in
                            }
                        }
                  }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    vc.viewModel.viewDidLoad = {
        if vc.reachabilityManager?.connection != .unavailable {
            vc.showLoading()
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
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Profile".localized)")
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
                    vc.buyerNameLbl.text = "\(User.loggedIn()?.firstName ?? "") \n \(User.loggedIn()?.lastName ?? "")"
                    vc.companyName.text = User.loggedIn()?.buyerCompanyDetails.first?.companyName
                    vc.ratingLbl.text = "\(User.loggedIn()?.rating ?? 1) / 5"
                    vc.segmentControl.setSelectedIndex(0)
                    vc.segmentControl.sendActions(for: .valueChanged)
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
    }
    return vc
  }
}

