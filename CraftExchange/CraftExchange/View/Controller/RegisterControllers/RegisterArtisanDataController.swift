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
    self.navigationItem.rightBarButtonItem = roleBarButton()
    self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none

    self.form +++
      Section()
    <<< LabelRow() {
      $0.cell.height = { 220.0 }
      $0.cell.imageView?.frame = $0.cell.contentView.frame
      $0.cell.imageView?.image = UIImage(named: "logo-underlying-text")
    }
    <<< LabelRow() {
      $0.title = "Artisan id: \(self.weaverID ?? "")"
      $0.cellStyle = .default
      $0.cell.textLabel?.textAlignment = .center
      $0.cell.textLabel?.textColor = .darkGray
      $0.cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
      $0.cell.height = { 40.0 }
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "First name"
      $0.cell.height = { 80.0 }
      self.viewModel.firstname.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Last name"
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.height = { 80.0 }
      self.viewModel.lastname.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Pincode"
      $0.cell.height = { 80.0 }
      self.viewModel.pincode.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedActionSheetRow() {
    $0.cell.titleLabel.text = "Cluster"
    $0.cell.options = ["Cluster1","Cluster2"]
    $0.cell.delegate = self
    $0.add(rule: RuleRequired())
    $0.cell.height = { 80.0 }
      /*$0.title = "Cluster"
      $0.tag = "ClusterRow"
      $0.options = ["Cluster1","Cluster2"]
      $0.options = self.viewModel.clusterArray.value?.compactMap{$0.clusterDescription}
      print("options cluster: \($0.options) clusterArray: \(self.viewModel.clusterArray.value)")
      $0.add(rule: RuleRequired())*/
    }.onChange({ (row) in
      print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
//      self.viewModel.cluster.value = self.viewModel.clusterArray.value?[row.indexPath?.row ?? 0]
//      self.viewModel.cluster.value = self.viewModel.clusterArray.value?[0]
      if let r = self.form.rowBy(tag: "ProductCategoryRow") as? MultipleSelectorRow<String> {
//        var catname = self.viewModel.cluster.value?.prodCategory.compactMap{$0.prodCatDescription}
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
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "District"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.district.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "State"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.state.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Mobile Number"
      $0.cell.height = { 80.0 }
      self.viewModel.mobNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Pan No."
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.valueTextField.autocapitalizationType = .allCharacters
      self.viewModel.panNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Address"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.addr.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< MultipleSelectorRow<String>() {
        $0.title = "Product Category"
        $0.options = []
//        self.viewModel.cluster.value?.prodCategory.compactMap{$0.prodCatDescription}
//      print("options prod cat: \($0.options) prodCatArray: \(self.viewModel.cluster.value?.prodCategory)")
        $0.tag = "ProductCategoryRow"
        $0.cell.height = { 44.0 }
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
      <<< RoundedButtonViewRow("REGNextCell") {
        $0.cell.titleLabel.text = "Fields are mandatory"
        $0.cell.compulsoryIcon.isHidden = false
        $0.cell.greyLineView.isHidden = false
        $0.cell.buttonView.borderColour = .black
        $0.cell.buttonView.backgroundColor = .black
        $0.cell.buttonView.setTitleColor(.white, for: .normal)
        $0.cell.buttonView.setTitle("Next", for: .normal)
        $0.cell.tag = 101
        $0.cell.delegate = self
        $0.cell.height = { 100.0 }
    }
    <<< RoundedButtonViewRow("REGHelpCell") {
        $0.cell.titleLabel.text = "In case of any help"
        $0.cell.compulsoryIcon.isHidden = true
        $0.cell.greyLineView.isHidden = true
        $0.cell.buttonView.borderColour = .black
        $0.cell.buttonView.backgroundColor = .white
        $0.cell.buttonView.setTitleColor(.black, for: .normal)
        $0.cell.buttonView.setTitle("Reach out to us", for: .normal)
        $0.cell.tag = 102
        $0.cell.delegate = self
        $0.cell.height = { 100.0 }
    }
    }

}

extension RegisterArtisanDataController: ButtonActionProtocol {
  func customButtonSelected(tag: Int) {
    switch tag {
    case 101:
      print("Next Selected")
      self.viewModel.nextSelected?()
    default:
      print("do nothing")
    }
  }
}
