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
    let storyboard = UIStoryboard(name: "myStoryboardName", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "LoginEmailController") as! LoginEmailController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString")
    }.dispose(in: vc.bag)
    
    vc.viewModel.performValidation = {
      if let username = vc.viewModel.username.value {
        self.fetch(username: username).bind(to: vc, context: .global(qos: .background)) { (_, responseString) in
          print("validation scene: \(responseString)")
        }.dispose(in: vc.bag)
      }
    }
    
    return vc
  }
}
