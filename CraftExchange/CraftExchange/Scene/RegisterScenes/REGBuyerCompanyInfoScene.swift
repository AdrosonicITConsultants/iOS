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
                    var errorIn = ""
                    if vc.viewModel.gstNo.value != nil && vc.viewModel.gstNo.value?.isNotBlank ?? false {
                        let val = vc.viewModel.gstNo.value?.isValidGST ?? false
                        if val == false {
                            isValid = false
                            errorIn = "gst"
                        }
                    }
                    if vc.viewModel.cinNo.value != nil && vc.viewModel.cinNo.value?.isNotBlank ?? false {
                        let val = vc.viewModel.cinNo.value?.isValidCIN ?? false
                        if val == false {
                            isValid = false
                            errorIn = "cin"
                        }
                    }
                    if vc.viewModel.pocEmailId.value != nil && vc.viewModel.pocEmailId.value?.isNotBlank ?? false {
                        let val = vc.viewModel.pocEmailId.value?.isValidEmailAddress ?? false
                        if val == false {
                            isValid = false
                            errorIn = "poc"
                        }
                    }
                    if isValid {
                        let newUser = createNewUser()
                        let controller = REGBuyerAddressInfoService(client: self.client).createScene(existingUser: newUser)
                        vc.navigationController?.pushViewController(controller, animated: true)
                    }else {
                        if errorIn == "poc" {
                            vc.alert("Please enter valid email id and phone number of point of contact.")
                        }
                        if errorIn == "gst" {
                            vc.alert("Please enter valid GST")
                        }
                        if errorIn == "cin" {
                            vc.alert("Please enter valid CIN")
                        }
                        
                    }
                }else {
                    vc.alert("Please enter valid PAN")
                }
            }else {
                vc.alert("Please enter all mandatory fields")
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
            newUser.profileImg = vc.viewModel.brandLogo.value
            let compName = vc.viewModel.companyName.value ?? nil
            let cin = vc.viewModel.cinNo.value ?? nil
            let panNo = vc.viewModel.panNo.value ?? ""
            let gstNo = vc.viewModel.gstNo.value ?? nil
            newUser.pancard = panNo
            let newCompDetails = buyerCompDetails.init(id: 0, companyName: compName, cin: cin, contact: "", gstNo: gstNo, logo: nil, compDesc: nil)
            newUser.buyerCompanyDetails = newCompDetails
            
            let newPointOfContact = pointOfContact.init(id: 0, contactNo: vc.viewModel.pocMobNo.value ?? "", email: vc.viewModel.pocEmailId.value ?? "", firstName: vc.viewModel.pocFirstName.value ?? "")
            newUser.buyerPointOfContact = newPointOfContact
            
            appDelegate?.registerUser = newUser
            return newUser
        }
        
        return vc
    }
}
