//
//  REGBuyerCompanyInfoController.swift
//  CraftExchange
//
//  Created by Preety Singh on 16/06/20.
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

class BuyerCompanyViewModel {
  var companyName = Observable<String?>(nil)
  var gstNo = Observable<String?>(nil)
  var cinNo = Observable<String?>(nil)
  var panNo = Observable<String?>(nil)
  var pocFirstName = Observable<String?>(nil)
  var pocLastName = Observable<String?>(nil)
  var pocMobNo = Observable<String?>(nil)
  var pocEmailId = Observable<String?>(nil)
  var brandLogo = Observable<String?>(nil)
  var nextSelected: (() -> Void)?
}

class REGBuyerCompanyInfoController: FormViewController {
  
  let viewModel = BuyerCompanyViewModel()
  var regEmail: String?
  var regPassword: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
        $0.title = "Tell us about your company"
        $0.cellStyle = .default
        $0.cell.textLabel?.textAlignment = .center
        $0.cell.textLabel?.textColor = .darkGray
        $0.cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        $0.cell.height = { 40.0 }
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Brand/ Company name"
        $0.cell.height = { 80.0 }
        self.viewModel.companyName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "GST Number"
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.gstNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "CIN Number"
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.cinNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "PAN Number"
        $0.cell.valueTextField.autocapitalizationType = .allCharacters
        $0.cell.height = { 80.0 }
        self.viewModel.panNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< LabelRow() {
        $0.title = "Point of Contact Details"
        $0.cell.height = { 80.0 }
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Point of contact's first name"
        $0.cell.height = { 80.0 }
        self.viewModel.pocFirstName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Point of contact's last name"
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.pocLastName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Point of contact's email address"
        $0.cell.height = { 80.0 }
        self.viewModel.pocEmailId.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Point of contact's mobile number"
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.pocMobNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
      }
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
          $0.cell.titleLabel.text = "Next up: Address details"
          $0.cell.compulsoryIcon.isHidden = true
          $0.cell.greyLineView.isHidden = true
          $0.cell.buttonView.borderColour = .white
          $0.cell.buttonView.backgroundColor = .white
          $0.cell.buttonView.setTitleColor(.lightGray, for: .normal)
          $0.cell.buttonView.setTitle("Privacy Policy", for: .normal)
          $0.cell.tag = 102
          $0.cell.delegate = self
          $0.cell.height = { 100.0 }
      }
    }

}

extension REGBuyerCompanyInfoController: ButtonActionProtocol {
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
