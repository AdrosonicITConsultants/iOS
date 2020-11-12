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
      if vc.isTCAccepted {
        let userObj = createNewUser()
        var imgData: Data?
        if let data = vc.uploadImageButton.image(for: .normal)?.pngData() {
            imgData = data
        } else if let data = vc.uploadImageButton.image(for: .normal)?.jpegData(compressionQuality: 1) {
            imgData = data
        }
        self.fetch(newUser: userObj.toJSON(updateAddress: false, buyerComp: false), imageData:imgData ).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                {
                  if (jsonDict["valid"] as? Bool) == true {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.registerUser = nil
                    DispatchQueue.main.async {
                      
                        vc.alert("Registration Successful", "Welcome to Crafts Exchange. Please Login to Continue".localized) { (alert) in
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
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Registration Failed".localized)")
                    }
                  }
                } else {
                  DispatchQueue.main.async {
                    vc.alert("Registration Failed".localized)
                  }
                }
            } catch let error as NSError {
              DispatchQueue.main.async {
                vc.alert(error.description)
              }
            }
        }.dispose(in: vc.bag)
      }else {
        vc.alert("Please accept Terms and Conditions for proceeding ahead!".localized)
      }
      
    }
    
    func createNewUser() -> CXUser {
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
      var finalUser = appDelegate?.registerUser ?? CXUser()
        
      finalUser.weaverId = newUser.weaverId
      finalUser.email = newUser.email
      finalUser.password = newUser.password
      finalUser.refRoleId = 1
      finalUser.clusterId = newUser.clusterId
      finalUser.firstName = newUser.firstName
      finalUser.lastName = newUser.lastName
      finalUser.mobile = newUser.mobile
      finalUser.pancard = newUser.pancard
      finalUser.address = newUser.address
      finalUser.productCategoryIds = vc.viewModel.selectedProdCat.value

      appDelegate?.registerUser = finalUser
      return finalUser
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
            self.fetch(newUser: userObj.toJSON(updateAddress: false, buyerComp: false), imageData: userObj.profileImg).bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            DispatchQueue.main.async {
              vc.hideLoading()
            }
              do {
                  if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                  {
                    if (jsonDict["valid"] as? Bool) == true {
                      DispatchQueue.main.async {
                        
                        vc.alert("Registration Successful", "Welcome to Crafts Exchange. Please Login to Continue".localized) { (alert) in
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
                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Registration Failed".localized)")
                      }
                    }
                  } else {
                    DispatchQueue.main.async {
                        vc.alert("Registration Failed".localized)
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
            vc.alert("Please enter valid links".localized)
        }
      }else {
        vc.alert("Please accept Terms and Conditions for proceeding ahead!".localized)
      }
    }
    
    func createNewUser() -> CXUser {
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
      var newUser = appDelegate?.registerUser ?? CXUser()
      
      newUser.email = existingUser.email
      newUser.password = existingUser.password
      newUser.refRoleId = existingUser.refRoleId
      newUser.firstName = existingUser.firstName ?? nil
      newUser.lastName = existingUser.lastName ?? nil
      newUser.mobile = existingUser.mobile ?? nil
      newUser.alternateMobile = existingUser.alternateMobile ?? nil
      newUser.designation = existingUser.designation ?? nil
      newUser.buyerCompanyDetails = existingUser.buyerCompanyDetails
      newUser.buyerPointOfContact = existingUser.buyerPointOfContact
      newUser.address = existingUser.address
      newUser.websiteLink = vc.viewModel.websiteLink.value ?? nil
      newUser.socialMediaLink = vc.viewModel.socialMediaLink.value ?? nil
        newUser.profileImg = existingUser.profileImg
      appDelegate?.registerUser = newUser
      return newUser
    }
    
    return vc
  }
}
