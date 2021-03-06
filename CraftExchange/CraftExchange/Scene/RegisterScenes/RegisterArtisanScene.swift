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
      if vc.isTCAccepted {
        self.fetch(newUser: newUser.toJSON()).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["valid"] as? Bool) == true {
                    DispatchQueue.main.async {
                      
                      vc.alert("Registration Successful", "Welcome to Crafts Exchange. Please Login to Continue") { (alert) in
                        do {
                          let client = try SafeClient(wrapping: CraftExchangeClient())
                          let controller = ValidateUserService(client: client).createScene()
                          let navigationController = UINavigationController(rootViewController: controller)
                          vc.present(navigationController, animated: true, completion: nil)
                        } catch let error {
                          print("Unable to load view:\n\(error.localizedDescription)")
                        }
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
      }else {
        vc.alert("Please accept Terms and Conditions for proceeding ahead!")
      }
      
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
      if vc.isTCAccepted {
        var isValid = true
        if vc.viewModel.websiteLink.value != nil && vc.viewModel.websiteLink.value?.isNotBlank ?? false {
          let urlValid = vc.viewModel.websiteLink.value?.isValidUrl ?? false
          if urlValid == false {
            isValid = false
          }
        }
        if vc.viewModel.socialMediaLink.value != nil && vc.viewModel.socialMediaLink.value?.isNotBlank ?? false {
          let urlValid = vc.viewModel.socialMediaLink.value?.isValidUrl ?? false
          if urlValid == false {
            isValid = false
          }
        }
        if isValid {
          vc.showLoading()
          let userObj = createNewUser()
          self.fetch(newUser: userObj.toJSON()).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            DispatchQueue.main.async {
              vc.hideLoading()
            }
              do {
                  if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                  {
                    if (jsonDict["valid"] as? Bool) == true {
                      DispatchQueue.main.async {
                        
                        vc.alert("Registration Successful", "Welcome to Crafts Exchange. Please Login to Continue") { (alert) in
                          do {
                            let client = try SafeClient(wrapping: CraftExchangeClient())
                            let controller = ValidateUserService(client: client).createScene()
                            let navigationController = UINavigationController(rootViewController: controller)
                            vc.present(navigationController, animated: true, completion: nil)
                          } catch let error {
                            print("Unable to load view:\n\(error.localizedDescription)")
                          }
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
        else {
          vc.alert("Please enter valid links")
        }
      }else {
        vc.alert("Please accept Terms and Conditions for proceeding ahead!")
      }
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
