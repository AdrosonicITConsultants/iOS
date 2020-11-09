//
//  RoleSelectionScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 28/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension LoginUserService {
  
  func createScene() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "LoginMarketController") as! LoginMarketController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.performAuthentication = {
      if vc.viewModel.username.value != nil && vc.viewModel.username.value?.isNotBlank ?? false && vc.viewModel.password.value != nil && vc.viewModel.password.value?.isNotBlank ?? false {
        let username = vc.viewModel.username.value ?? ""
        let password = vc.viewModel.password.value ?? ""
        vc.showLoading()
        self.fetch(username: username, password: password).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
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
                            vc.alert("\(jsonDict["errorMessage"] as? String ?? "Login Failed. Please validate your password.".localized)")
                        }
                        return
                    }
                    let userData = try JSONSerialization.data(withJSONObject: userObj, options: .prettyPrinted)
                    let loggedInUser = try? JSONDecoder().decode(User.self, from: userData)
                    loggedInUser?.saveOrUpdate()
                    DispatchQueue.main.async {
                        KeychainManager.standard.userAccessToken = dataDict["acctoken"] as? String ?? ""
                        KeychainManager.standard.userID = userObj["id"] as? Int ?? 0
                        KeychainManager.standard.username = userObj["firstName"] as? String ?? ""
                        let app = UIApplication.shared.delegate as? AppDelegate
                        app?.showDemoVideo = true
                        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
                        let tab = storyboard.instantiateViewController(withIdentifier: "MarketingTabbarController") as! MarketingTabbarController
                        tab.modalPresentationStyle = .fullScreen
                        vc.present(tab, animated: true, completion: nil)
                    }
                  }else {
                    DispatchQueue.main.async {
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Login Failed. Please validate your password.".localized)")
                    }
                  }
                } else {
                    DispatchQueue.main.async {
                        vc.alert("Login Failed. Please validate your password.".localized)
                    }
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                  vc.alert("\(error.description)")
                }
            }
        }.dispose(in: vc.bag)
      }
    }
    
    vc.viewModel.goToForgotPassword = {
        let controller = ForgotPasswordService(client: self.client).createScene()
        vc.present(controller, animated: true, completion: nil)
    }
    
    return vc
  }
}

