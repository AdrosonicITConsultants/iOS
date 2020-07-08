//
//  REGValidateWeaverScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension ValidateWeaverService {
  func createScene() -> UIViewController {
    let storyboard = UIStoryboard(name: "RegisterArtisan", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "REGValidateArtisanController") as! REGValidateArtisanController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString")
    }.dispose(in: vc.bag)
    
    vc.viewModel.performValidation = {
      if let weaverId = vc.viewModel.weaverId.value {
        self.fetch(weaverId: weaverId).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["errorMessage"] as? String) == nil {
                    DispatchQueue.main.async {
                      createUser()
                      let controller = REGValidateUserEmailService(client: self.client).createScene(weaverId: weaverId)
                      vc.navigationController?.pushViewController(controller, animated: true)
                    }
                  }else {
                    DispatchQueue.main.async {
                      vc.alert("Invalid Artisan Id")
                    }
                  }
                } else {
                  DispatchQueue.main.async {
                    vc.alert("Invalid Artisan Id")
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
    
    func createUser() {
        if let weaverId = vc.viewModel.weaverId.value {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.registerUser = CXUser()
            appDelegate?.registerUser?.weaverId = weaverId
        }
    }
    
    return vc
  }
}

