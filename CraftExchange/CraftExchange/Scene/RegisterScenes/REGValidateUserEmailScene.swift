//
//  REGValidateUserEmailScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension REGValidateUserEmailService {
  
  func createScene(weaverId: String?) -> UIViewController {
    let storyboard = UIStoryboard(name: "RegisterArtisan", bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "REGValidateUserEmailController") as! REGValidateUserEmailController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.sendOTP = {
      if (vc.viewModel.username.value != nil) && vc.viewModel.username.value != "" {
        let username = vc.viewModel.username.value ?? ""
        self.fetch(username: username).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
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
        vc.alert("Please enter email id")
      }
    }
    
    vc.viewModel.validateOTP = {
      if let username = vc.viewModel.username.value, let otp = vc.viewModel.otp.value {
        self.fetch(emailId: username, otp: otp).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["valid"] as? Bool) == true {
                    DispatchQueue.main.async {
                      let storyboard = UIStoryboard(name: "RegisterArtisan", bundle: Bundle.main)
                      let controller = storyboard.instantiateViewController(withIdentifier: "REGNewUserPasswordController") as! REGNewUserPasswordController
                      controller.weaverId = weaverId
                      controller.validatedEmailId = username
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
        vc.alert("Please enter email id & OTP")
      }
    }
    
    return vc
  }
}
