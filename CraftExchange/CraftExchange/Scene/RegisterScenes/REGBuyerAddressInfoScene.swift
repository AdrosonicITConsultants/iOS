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
        if vc.viewModel.addr1.value != nil && vc.viewModel.addr1.value?.isNotBlank ?? false &&
          vc.viewModel.country.value != nil && vc.viewModel.country.value?.isNotBlank ?? false &&
          vc.viewModel.pincode.value != nil && vc.viewModel.pincode.value?.isNotBlank ?? false {
          if vc.viewModel.pincode.value?.isValidPincode ?? false {
            let newUser = createNewUser()
            let controller = RegisterArtisanService(client: self.client).createScene(existingUser: newUser)
            vc.navigationController?.pushViewController(controller, animated: true)
          }else {
            vc.alert("Please enter valid Pincode")
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
        newUser.firstName = existingUser.firstName ?? nil
        newUser.lastName = existingUser.lastName ?? nil
        newUser.mobile = existingUser.mobile ?? nil
        newUser.alternateMobile = existingUser.alternateMobile ?? nil
        newUser.designation = existingUser.designation ?? nil
        newUser.buyerCompanyDetails = existingUser.buyerCompanyDetails
        newUser.buyerPointOfContact = existingUser.buyerPointOfContact
        let selectedCountryObj = vc.allCountries?.filter("%K == %@", "name", vc.viewModel.country.value).first
        let addr1 = vc.viewModel.addr1.value ?? nil
        let addr2 = vc.viewModel.addr2.value ?? nil
        let city = vc.viewModel.city.value ?? nil
        let landmark = vc.viewModel.landmark.value ?? nil
        let state = vc.viewModel.state.value ?? nil
        let street = vc.viewModel.street.value ?? nil
        let pin = vc.viewModel.pincode.value ?? nil
        
        let newAddr = LocalAddress.init(id: 0, addrType: (0,"test"), country: (countryId: selectedCountryObj?.entityID, countryName: selectedCountryObj?.name) as? (countryId: Int, countryName: String), city: city, district: nil, landmark: landmark, line1: addr1, line2: addr2, pincode: pin, state: state, street: street, userId: 0)
        newUser.address = newAddr
        
        return newUser
      }
      
      return vc
    }
}
