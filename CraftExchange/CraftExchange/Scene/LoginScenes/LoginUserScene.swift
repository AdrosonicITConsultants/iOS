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
  
  func createScene(username:String) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "LoginMarketController") as! LoginMarketController
    vc.viewModel.username.value = username
    
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
                        if KeychainManager.standard.userRole == "Artisan" {
                            let controller = HomeScreenService(client: self.client).createScene()
                            vc.present(controller, animated: true, completion: nil)
                        }else {
                            let controller = HomeScreenService(client: self.client).createBuyerScene()
                            vc.present(controller, animated: true, completion: nil)
                        }
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
      vc.navigationController?.pushViewController(controller, animated: true)
    }
    
    vc.viewModel.goToRegister = {
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
      appDelegate?.registerUser = nil
      if KeychainManager.standard.userRoleId == 1 {
        let controller = ValidateWeaverService(client: self.client).createScene()
        vc.navigationController?.pushViewController(controller, animated: true)
      }else {
        let controller = REGValidateUserEmailService(client: self.client).createScene(weaverId: nil)
        vc.navigationController?.pushViewController(controller, animated: true)
      }
      
    }
    
    return vc
  }
}

