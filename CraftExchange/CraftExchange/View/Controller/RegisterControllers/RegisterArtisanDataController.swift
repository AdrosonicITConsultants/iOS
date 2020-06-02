//
//  RegisterArtisanDataController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD

class ArtisanDataViewModel {
  var firstname = Observable<String?>(nil)
  var lastname = Observable<String?>(nil)
  var pincode = Observable<String?>(nil)
//  var cluster = Observable<ClusterDetails?>(nil)
  var selectedProdCat = Observable<[Int]?>(nil)
  var district = Observable<String?>(nil)
  var state = Observable<String?>(nil)
  var mobNo = Observable<String?>(nil)
  var panNo = Observable<String?>(nil)
  var addr = Observable<String?>(nil)
//  var clusterArray = Observable<[ClusterDetails]?>(nil)
//  var clusterNameArray = Observable<[String]?>(nil)
  var selectedClusterId = Observable<Int?>(nil)
  var nextSelected: (() -> Void)?
}

class RegisterArtisanDataController: FormViewController {
  
  let viewModel = ArtisanDataViewModel()
  var weaverID: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
//      DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                  self.form
                        +++ Section("")
                        <<< LabelRow() {
                          $0.title = "Artisan id: \(self.weaverID ?? "")"
                        }
                        <<< TextRow() {
                          $0.title = "First name"
                          $0.add(rule: RuleRequired())
                        }.onChange({ (row) in
                          self.viewModel.firstname.value = row.value
                        })
                        <<< TextRow() {
                          $0.title = "Last name"
                        }.onChange({ (row) in
                          self.viewModel.lastname.value = row.value
                        })
                        <<< TextRow() {
                          $0.title = "Pincode"
                          $0.add(rule: RuleRequired())
                        }.onChange({ (row) in
                          self.viewModel.pincode.value = row.value
                        })
                        <<< ActionSheetRow<String>() {
                          $0.title = "Cluster"
                          $0.tag = "ClusterRow"
                          $0.options = ["Cluster1","Cluster2"]
//                          $0.options = self.viewModel.clusterArray.value?.compactMap{$0.clusterDescription}
//                          print("options cluster: \($0.options) clusterArray: \(self.viewModel.clusterArray.value)")
                          $0.add(rule: RuleRequired())
                        }.onChange({ (row) in
                          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            //              self.viewModel.cluster.value = self.viewModel.clusterArray.value?[row.indexPath?.row ?? 0]
//                          self.viewModel.cluster.value = self.viewModel.clusterArray.value?[0]
                          if let r = self.form.rowBy(tag: "ProductCategoryRow") as? MultipleSelectorRow<String> {
      //                      var catname = self.viewModel.cluster.value?.prodCategory.compactMap{$0.prodCatDescription}
                            if row.value == "Cluster1" {
                              self.viewModel.selectedClusterId.value = 1
                              r.options = ["Saree","Razai"]
                            }else {
                              self.viewModel.selectedClusterId.value = 2
                              r.options = ["Saree"]
                            }
                            r.value = []
                            self.viewModel.selectedProdCat.value = []
                            r.updateCell()
                          }
                        })
                        <<< MultipleSelectorRow<String>() {
                          $0.title = "Product Category"
                          $0.options = [] //self.viewModel.cluster.value?.prodCategory.compactMap{$0.prodCatDescription}
      //                    print("options prod cat: \($0.options) prodCatArray: \(self.viewModel.cluster.value?.prodCategory)")
                          $0.tag = "ProductCategoryRow"
                        }.onChange({ (actionSheetRow) in
                          actionSheetRow.value?.forEach({ (str) in
                            var codeToAdd = 0
                            if str == "Saree" {
                              codeToAdd = 1
                            }else if str == "Razai" {
                              codeToAdd = 2
                            }
                            if !(self.viewModel.selectedProdCat.value?.contains(codeToAdd) ?? false) {
                              self.viewModel.selectedProdCat.value?.append(codeToAdd)
                            }
                          })
                          
                        })
                        <<< TextRow() {
                          $0.title = "District"
                        }.onChange({ (row) in
                          self.viewModel.district.value = row.value
                        })
                        <<< TextRow() {
                          $0.title = "State"
                        }.onChange({ (row) in
                          self.viewModel.state.value = row.value
                        })
                        <<< PhoneRow() {
                          $0.title = "Mobile Number"
                          $0.add(rule: RuleRequired())
                        }.onChange({ (row) in
                          self.viewModel.mobNo.value = row.value
                        })
                        <<< TextRow() {
                          $0.title = "Pan No."
                        }.onChange({ (row) in
                          self.viewModel.panNo.value = row.value
                        })
                        <<< TextRow() {
                          $0.title = "Address"
                        }.onChange({ (row) in
                          self.viewModel.addr.value = row.value
                        })
                        <<< ButtonRow() {
                          $0.title = "Next"
                          $0.tag = "NextButton"
                        }.onCellSelection({ (cell, row) in
                          print("\(row.tag ?? "NextButton")")
                          self.viewModel.nextSelected?()
                        })
//                }
    }

}
