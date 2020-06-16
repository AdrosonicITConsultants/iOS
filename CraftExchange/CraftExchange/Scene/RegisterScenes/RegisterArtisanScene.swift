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
  
  func createScene(newUser: CXUser) -> UIViewController {
    
    let storyboard = UIStoryboard(name: "RegisterArtisan", bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "RegisterArtisanController") as! RegisterArtisanController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.completeRegistration = {
//      let newAddr = LocalAddress.init(id: 0, addrType: (0,"addr type"), country: (1,"India"), city: "city str", district: "district str", landmark: "landmark str", line1: "line 1 str", line2: "line 2 str", pincode: "pin123", state: "state str", street: "street str", userId: 0)
//      let newUser = CXUser.init(address: newAddr, alternateMobile: "123", buyerCompanyDetails: nil, buyerPointOfContact: nil, clusterId: 1, designation: nil, email: email, firstName: "ps", lastName: "iOS", mobile: "676", pancard: "pan676", password: password, productCategoryIds: [1,2], refRoleId: 1, socialMediaLink: "www.adrosonic.com", weaverId: weaverId, websiteLink: "www.adrosonic.com")
      
      self.fetch(newUser: newUser.toJSON()).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
          do {
              if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
              {
                if (jsonDict["valid"] as? Bool) == true {
                  DispatchQueue.main.async {
                    
                    vc.alert("Registration Successful", "Welcome to Crafts Exchange. Please Login to Continue") { (alert) in
                      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                      let controller = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
                      vc.navigationController?.present(controller, animated: true, completion: nil)
                    }
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

extension RegisterArtisanService {
  
  func createScene(existingUser: CXUser) -> UIViewController {
    
    let storyboard = UIStoryboard(name: "RegisterArtisan", bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "RegisterBuyerController") as! RegisterBuyerController
    
    client.errors.bind(to: vc.reactive.userErrors)
    
    self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
        print("responseString:")
    }.dispose(in: vc.bag)
    
    vc.viewModel.completeRegistration = {
      let userObj = createNewUser()
      self.fetch(newUser: userObj.toJSON()).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
          do {
              if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
              {
                if (jsonDict["valid"] as? Bool) == true {
                  DispatchQueue.main.async {
                    
                    vc.alert("Registration Successful", "Welcome to Crafts Exchange. Please Login to Continue") { (alert) in
                      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                      let controller = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
                      vc.navigationController?.present(controller, animated: true, completion: nil)
                    }
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
    
    func createNewUser() -> CXUser {
      var newUser = CXUser()
      
      newUser.email = existingUser.email
      newUser.password = existingUser.password
      newUser.refRoleId = existingUser.refRoleId
      newUser.firstName = existingUser.firstName ?? ""
      newUser.lastName = existingUser.lastName ?? ""
      newUser.mobile = existingUser.mobile ?? ""
      newUser.alternateMobile = existingUser.alternateMobile ?? ""
      newUser.designation = existingUser.designation ?? ""
      newUser.buyerCompanyDetails = existingUser.buyerCompanyDetails
      newUser.buyerPointOfContact = existingUser.buyerPointOfContact
      newUser.address = existingUser.address
      newUser.websiteLink = vc.viewModel.websiteLink.value ?? ""
      newUser.socialMediaLink = vc.viewModel.socialMediaLink.value ?? ""
      
      return newUser
    }
    
    return vc
  }
}
