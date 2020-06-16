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
    let vc = storyboard.instantiateViewController(withIdentifier: "LoginPasswordController") as! LoginPasswordController
    vc.viewModel.username.value = username
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.performAuthentication = {
      if let username = vc.viewModel.username.value, let password = vc.viewModel.password.value {
        self.fetch(username: username, password: password).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["data"] as? Dictionary<String,Any>) != nil {
                    print("logged In User: \(jsonDict)")
                    DispatchQueue.main.async {
                      vc.alert("User Logged In Successfully")
                    }
                  }else {
                    DispatchQueue.main.async {
                      vc.alert("\(jsonDict["errorMessage"] as? String ?? "Login Failed. Please validate your password.")")
                    }
                  }
                } else {
                    DispatchQueue.main.async {
                      vc.alert("Login Failed. Please validate your password.")
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
      if KeychainManager.standard.userRoleId == 1 {
        let controller = ValidateWeaverService(client: self.client).createScene()
        vc.navigationController?.pushViewController(controller, animated: true)
      }else {
//        vc.alert("Feature Comming Soon!!!")
        let controller = REGValidateUserEmailService(client: self.client).createScene(weaverId: nil)
        vc.navigationController?.pushViewController(controller, animated: true)
      }
      
    }
    
    return vc
  }
}

