//
//  REGBuyerCompanyInfoScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 16/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit
import Eureka

extension REGBuyerCompanyInfoService {
  func createScene(existingUser: CXUser) -> UIViewController {
      
      let vc = REGBuyerCompanyInfoController(style: .plain)
      
      client.errors.bind(to: vc.reactive.userErrors)
      
      self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
          print("responseString:")
      }.dispose(in: vc.bag)

      vc.viewModel.nextSelected = {
        if vc.viewModel.companyName.value != nil && vc.viewModel.companyName.value?.isNotBlank ?? false &&
          vc.viewModel.panNo.value != nil && vc.viewModel.panNo.value?.isNotBlank ?? false {
          if vc.viewModel.panNo.value?.isValidPAN ?? false {
            var isValid = true
            if vc.viewModel.pocEmailId.value != nil && vc.viewModel.pocEmailId.value?.isNotBlank ?? false {
              let val = vc.viewModel.pocEmailId.value?.isValidEmailAddress ?? false
              if val == false {
                isValid = false
              }
            }
            if vc.viewModel.pocMobNo.value != nil && vc.viewModel.pocMobNo.value?.isNotBlank ?? false {
              let val = vc.viewModel.pocMobNo.value?.isValidPhoneNumber ?? false
              if val == false {
                isValid = false
              }
            }
            if isValid {
              let newUser = createNewUser()
              let controller = REGBuyerAddressInfoService(client: self.client).createScene(existingUser: newUser)
              vc.navigationController?.pushViewController(controller, animated: true)
            }else {
              vc.alert("Please enter valid email id and phone number of point of contact.")
            }
          }else {
            vc.alert("Please enter valid PAN")
          }
        }else {
          vc.alert("Please enter all mandatory fields")
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

        let newCompDetails = buyerCompDetails.init(id: 0, companyName: "\(vc.viewModel.companyName.value ?? "")", cin: "\(vc.viewModel.cinNo.value ?? "")", contact: "\(vc.viewModel.panNo.value ?? "")", gstNo: "\(vc.viewModel.gstNo.value ?? "")", logo: "logo")
        newUser.buyerCompanyDetails = newCompDetails
        
        let newPointOfContact = pointOfContact.init(id: 0, contactNo: "\(vc.viewModel.pocMobNo.value ?? "")", email: "\(vc.viewModel.pocEmailId.value ?? "")", firstName: "\(vc.viewModel.pocFirstName.value ?? "")", lastName: "\(vc.viewModel.pocLastName.value ?? "")")
        newUser.buyerPointOfContact = newPointOfContact
        
        return newUser
      }
      
      return vc
    }
}
