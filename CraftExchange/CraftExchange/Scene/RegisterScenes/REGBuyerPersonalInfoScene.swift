//
//  REGBuyerPersonalInfoScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit
import Eureka

extension REGBuyerPersonalInfoService {
  func createScene(email: String, password:String) -> UIViewController {
      
      let vc = REGBuyerPersonalInfoController(style: .plain)
      
      client.errors.bind(to: vc.reactive.userErrors)
      
      self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
          print("responseString:")
      }.dispose(in: vc.bag)
      
      func fetchCountries() {
        self.fetch().bind(to: vc, context: .global(qos: .background)) { (_, countryArray) in
  //        vc.viewModel.clusterArray.value = []
            do {
                if (countryArray.count > 0) {
  //                vc.viewModel.clusterArray.value = clusterArray
                  
                  countryArray.forEach( {clusterObj in
  //                    clusterObj.saveOrUpdate()
  //                    vc.viewModel.clusterArray.value?.append(clusterObj)
                    }
                  )
                }else {
                  DispatchQueue.main.async {
                    vc.alert("No Country Data Found")
                  }
                }
            }
        }.dispose(in: vc.bag)
      }
      
      fetchCountries()

      vc.viewModel.nextSelected = {
        if let name = vc.viewModel.firstname.value,
          let lastNm = vc.viewModel.lastname.value,
          let number = vc.viewModel.mobNo.value {
          let newUser = createNewUser()
          let controller = REGBuyerCompanyInfoService(client: self.client).createScene(existingUser: newUser)
          vc.navigationController?.pushViewController(controller, animated: true)
        }else {
          vc.alert("Please enter all mandatory fields")
        }
      }
      
      func createNewUser() -> CXUser {
        var newUser = CXUser()
        
        newUser.email = email
        newUser.password = password
        newUser.refRoleId = 2
        newUser.firstName = vc.viewModel.firstname.value ?? ""
        newUser.lastName = vc.viewModel.lastname.value ?? ""
        newUser.mobile = vc.viewModel.mobNo.value ?? ""
        newUser.alternateMobile = vc.viewModel.alternateMobNo.value ?? ""
        newUser.designation = vc.viewModel.designation.value ?? ""

        return newUser
      }
      
      return vc
    }
}
