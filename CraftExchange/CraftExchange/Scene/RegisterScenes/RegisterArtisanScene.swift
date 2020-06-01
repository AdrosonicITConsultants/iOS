//
//  RegisterArtisanScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension RegisterArtisanService {
  
  func createScene(weaverId: String, email: String, password:String) -> UIViewController {
    let storyboard = UIStoryboard(name: "RegisterArtisan", bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "RegisterArtisanController") as! RegisterArtisanController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.completeRegistration = {
      let newAddr = LocalAddress.init(id: 0, addrType: (0,"addr type"), country: (1,"India"), city: "city str", district: "district str", landmark: "landmark str", line1: "line 1 str", line2: "line 2 str", pincode: "pin123", state: "state str", street: "street str", userId: 0)
      let newUser = CXUser.init(address: newAddr, alternateMobile: "123", buyerCompanyDetails: nil, buyerPointOfContact: nil, clusterId: 1, designation: nil, email: email, firstName: "ps", lastName: "iOS", mobile: "676", pancard: "pan676", password: password, productCategoryIds: [1,2], refRoleId: 1, socialMediaLink: "www.adrosonic.com", weaverId: weaverId, websiteLink: "www.adrosonic.com")
//      newUser.weaverId = weaverId
//      newUser.email = email
//      newUser.password = password
//      newUser.refRoleId = 1
      
      self.fetch(newUser: newUser.toJSON()).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
          do {
              if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
              {
                if (jsonDict["valid"] as? Bool) == true {
                  DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let controller = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
                    vc.navigationController?.present(controller, animated: true, completion: nil)
                  }
                }else {
                  DispatchQueue.main.async {
                    vc.alert("\(jsonDict["errorMessage"] as? String ?? "Registration Failed")")
                  }
                }
              } else {
                DispatchQueue.main.async {
                  vc.alert("Registration Failed")
                }
              }
          } catch let error as NSError {
            DispatchQueue.main.async {
              vc.alert(error.description)
            }
          }
      }.dispose(in: vc.bag)
    }
    
    return vc
  }
}
