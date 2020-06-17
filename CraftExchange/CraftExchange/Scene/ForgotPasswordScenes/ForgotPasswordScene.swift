//
//  ForgotPasswordScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension ForgotPasswordService {
  
  func createScene() -> UIViewController {
    let storyboard = UIStoryboard(name: "ForgotPassword", bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordController") as! ForgotPasswordController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.sendOTP = {
      if (vc.viewModel.username.value != nil) && vc.viewModel.username.value?.isNotBlank ?? false && vc.viewModel.username.value?.isValidEmailAddress ?? false {
        vc.showLoading()
        let username = vc.viewModel.username.value ?? ""
        vc.sendOTPButton.isEnabled = false
        vc.sendOTPButton.isUserInteractionEnabled = false
        self.fetch(username: username).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
          DispatchQueue.main.async {
            vc.hideLoading()
            vc.sendOTPButton.isEnabled = true
            vc.sendOTPButton.isUserInteractionEnabled = true
          }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["valid"] as? Bool) == true {
                    DispatchQueue.main.async {
                      vc.alert("\(jsonDict["data"] as? String ?? "OTP Sent Successfully")")
                    }
                  }else {
                    DispatchQueue.main.async {
                      vc.alert("\(jsonDict["errorMessage"] as? String ?? "OTP Sending Failed")")
                    }
                  }
                } else {
                  DispatchQueue.main.async {
                    vc.alert("OTP Sending Failed")
                  }
                }
            } catch let error as NSError {
              DispatchQueue.main.async {
                vc.alert(error.description)
              }
            }
        }.dispose(in: vc.bag)
      }else {
        vc.alert("Please enter valid email id")
      }
    }
    
    vc.viewModel.validateOTP = {
      if (vc.viewModel.username.value != nil) && vc.viewModel.username.value?.isNotBlank ?? false && vc.viewModel.username.value?.isValidEmailAddress ?? false && (vc.viewModel.otp.value != nil) && vc.viewModel.otp.value?.isNotBlank ?? false {
        let username = vc.viewModel.username.value ?? ""
        let otp = vc.viewModel.otp.value ?? ""
        vc.showLoading()
        self.fetch(emailId: username, otp: otp).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
          DispatchQueue.main.async {
            vc.hideLoading()
          }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["valid"] as? Bool) == true {
                    DispatchQueue.main.async {
                      let controller = ResetPasswordService(client: self.client).createScene(username: username)
                      vc.navigationController?.pushViewController(controller, animated: true)
                    }
                  }else {
                    DispatchQueue.main.async {
                      vc.alert("\(jsonDict["errorMessage"] as? String ?? "OTP Validation Failed")")
                    }
                  }
                } else {
                  DispatchQueue.main.async {
                    vc.alert("OTP Validation Failed")
                  }
                }
            } catch let error as NSError {
              DispatchQueue.main.async {
                vc.alert(error.description)
              }
            }
        }.dispose(in: vc.bag)
      }else {
        vc.alert("Please enter valid email id & OTP")
      }
    }
    
    return vc
  }
}
