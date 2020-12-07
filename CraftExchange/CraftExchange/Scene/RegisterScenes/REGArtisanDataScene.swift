//
//  REGArtisanDataScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit
import Eureka

extension REGArtisanInfoInputService {
    
    func createScene(weaverId: String, email: String, password:String) -> UIViewController {
        
        let vc = RegisterArtisanDataController(style: .plain)
        vc.weaverID = weaverId
        
        client.errors.bind(to: vc.reactive.userErrors)
        
        self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
            print("responseString:")
        }.dispose(in: vc.bag)
        
        func fetchClusters() {
            self.fetch().bind(to: vc, context: .global(qos: .background)) { (_, clusterArray) in
                do {
                    if (clusterArray.count > 0) {
                        DispatchQueue.main.async {
                            vc.allClusters = clusterArray
                            let row = vc.form.rowBy(tag: "ClusterRow") as? RoundedActionSheetRow
                            row?.cell.options = clusterArray.compactMap {$0.clusterDescription}
                            row?.updateCell()
                        }
                        clusterArray.forEach( {clusterObj in
                            clusterObj.saveOrUpdate()
                            }
                        )
                    }else {
                        DispatchQueue.main.async {
                            vc.alert("No Cluster Data Found")
                        }
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.viewModel.viewDidAppear = {
            fetchClusters()
        }
        
        vc.viewModel.nextSelected = {
            if vc.viewModel.firstname.value != nil && vc.viewModel.firstname.value?.isNotBlank ?? false && vc.viewModel.pincode.value != nil && vc.viewModel.pincode.value?.isNotBlank ?? false && vc.viewModel.mobNo.value != nil && vc.viewModel.mobNo.value?.isNotBlank ?? false  && vc.viewModel.selectedClusterId.value != nil {
                var isValid = true
                let pincode = vc.viewModel.pincode.value ?? ""
                let mobNo = vc.viewModel.mobNo.value ?? ""
                if pincode.isValidPincode {
                    if mobNo.isValidPhoneNumber {
                        var isValid = true
                        if vc.viewModel.panNo.value != nil && vc.viewModel.panNo.value?.isNotBlank ?? false {
                            let val = vc.viewModel.panNo.value?.isValidPAN ?? false
                            if val == false {
                                isValid = false
                            }
                        }
                        if isValid {
                            let newUser = createNewUser()
                            let controller = RegisterArtisanService(client: self.client).createScene(newUser: newUser)
                            vc.navigationController?.pushViewController(controller, animated: true)
                        }else {
                            vc.alert("Please enter valid PAN".localized)
                        }
                    }else {
                        vc.alert("Please enter valid phone number".localized)
                    }
                }else {
                    vc.alert("Please enter valid pincode".localized)
                }
            }else {
                vc.alert("Please enter all mandatory fields".localized)
            }
        }
        
        func createNewUser() -> CXUser {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            var newUser = appDelegate?.registerUser ?? CXUser()
            
            newUser.weaverId = weaverId
            newUser.email = email
            newUser.password = password
            newUser.refRoleId = 1
            newUser.clusterId = vc.viewModel.selectedClusterId.value ?? 1
            newUser.firstName = vc.viewModel.firstname.value ?? nil
            newUser.lastName = vc.viewModel.lastname.value ?? nil
            newUser.mobile = vc.viewModel.mobNo.value ?? nil
            newUser.pancard = vc.viewModel.panNo.value ?? nil
            //      newUser.productCategoryIds = vc.viewModel.selectedProdCat.value
            
            let newAddr = LocalAddress.init(id: 0, addrType: (1,"Registered"), country: (1,"India"), city: "", district: "\(vc.viewModel.district.value ?? "")", landmark: "", line1: "\(vc.viewModel.addr.value ?? "")", line2: "", pincode: "\(vc.viewModel.pincode.value ?? "")", state: "\(vc.viewModel.state.value ?? "")", street: "", userId: 0)
            newUser.address = newAddr
            
            appDelegate?.registerUser = newUser
            return newUser
        }
        
        return vc
    }
}
