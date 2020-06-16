//
//  REGBuyerAddressInfoScene.swift
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

extension REGBuyerAddressInfoService {
  func createScene(existingUser: CXUser) -> UIViewController {
      
      let vc = REGBuyerAddressInfoController(style: .plain)
      
      client.errors.bind(to: vc.reactive.userErrors)
      
      self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
          print("responseString:")
      }.dispose(in: vc.bag)

      vc.viewModel.nextSelected = {
        if vc.viewModel.addr1.value != nil && vc.viewModel.addr1.value != "" &&
          vc.viewModel.country.value != nil && vc.viewModel.country.value != "" &&
          vc.viewModel.pincode.value != nil && vc.viewModel.pincode.value != "" {
          let newUser = createNewUser()
          let controller = RegisterArtisanService(client: self.client).createScene(existingUser: newUser)
          vc.navigationController?.pushViewController(controller, animated: true)
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
        newUser.buyerCompanyDetails = existingUser.buyerCompanyDetails
        newUser.buyerPointOfContact = existingUser.buyerPointOfContact

        let newAddr = LocalAddress.init(id: 0, addrType: (0,"\(vc.viewModel.addr1.value ?? "")"), country: (1,"India"), city: "\(vc.viewModel.city.value ?? "")", district: nil, landmark: nil, line1: "\(vc.viewModel.addr1.value ?? "")", line2: "\(vc.viewModel.addr2.value ?? "")", pincode: "\(vc.viewModel.pincode.value ?? "")", state: "\(vc.viewModel.state.value ?? "")", street: "\(vc.viewModel.street.value ?? "")", userId: 0)
        newUser.address = newAddr
        
        return newUser
      }
      
      return vc
    }
}
