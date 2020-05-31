//
//  ResetPasswordScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension ResetPasswordService {
  
  func createScene(username:String) -> UIViewController {
    let storyboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordController") as! ResetPasswordController
    vc.viewModel.username.value = username
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.preformResetPassword = {
      if let username = vc.viewModel.username.value, let password = vc.viewModel.password.value, let confirmPass = vc.viewModel.confirmPassword.value {
        if password == confirmPass {
          self.fetch(username: username, password: password).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
              do {
                  if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                  {
                    if (jsonDict["valid"] as? Bool) == true {
                      DispatchQueue.main.async {
//                        vc.alert("Password Reset Successfully")
                        let storyboard = UIStoryboard(name: "ForgotPassword", bundle: Bundle.main)
                        let controller = storyboard.instantiateViewController(withIdentifier: "PwdResetSuccessfulController") as! PwdResetSuccessfulController
                        vc.navigationController?.present(controller, animated: true, completion: nil)
                      }
                    }else {
                      DispatchQueue.main.async {
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Password Reset Failed.")")
                      }
                    }
                  } else {
                      DispatchQueue.main.async {
                        vc.alert("Password Reset Failed.")
                      }
                  }
              } catch let error as NSError {
                  DispatchQueue.main.async {
                    vc.alert("\(error.description)")
                  }
              }
          }.dispose(in: vc.bag)
        }else {
          vc.alert("Password & Confirm password mismatch.")
        }
        
      }else {
        vc.alert("Please enter password & confirm your password")
      }
    }
    
    return vc
  }
}

