//
//  ValidateUserScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension ValidateUserService {
  func createScene() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "LoginEmailController") as! LoginEmailController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString")
    }.dispose(in: vc.bag)
    
    vc.viewModel.performValidation = {
      if let username = vc.viewModel.username.value {
        self.fetch(username: username).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["data"] as? String) == "Valid" {
                    DispatchQueue.main.async {
                      let controller = LoginUserService(client: self.client).createScene(username:username)
                      vc.navigationController?.pushViewController(controller, animated: true)
                    }
                  }else {
                    DispatchQueue.main.async {
                      vc.alert("Invalid User Email Id or Mobile Number")
                    }
                  }
                } else {
                  DispatchQueue.main.async {
                    vc.alert("Invalid User Email Id or Mobile Number")
                  }
                }
            } catch let error as NSError {
              DispatchQueue.main.async {
                vc.alert(error.description)
              }
            }
        }.dispose(in: vc.bag)
      }
    }
    
    vc.viewModel.goToRegister = {
      if KeychainManager.standard.userRoleId == 1 {
        let controller = ValidateWeaverService(client: self.client).createScene()
        vc.navigationController?.pushViewController(controller, animated: true)
      }else {
        vc.alert("Feature Comming Soon!!!")
      }
    }
    
    return vc
  }
}
