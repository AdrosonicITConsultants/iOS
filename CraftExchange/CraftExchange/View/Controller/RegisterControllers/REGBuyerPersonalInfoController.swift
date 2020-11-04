//
//  REGBuyerPersonalInfoController.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/06/20.
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

class BuyerDataViewModel {
    var firstname = Observable<String?>(nil)
    var lastname = Observable<String?>(nil)
    var mobNo = Observable<String?>(nil)
    var alternateMobNo = Observable<String?>(nil)
    var designation = Observable<String?>(nil)
    var nextSelected: (() -> Void)?
    var viewDidAppear: (() -> Void)?
}

class REGBuyerPersonalInfoController: FormViewController {
  
  var viewModel = BuyerDataViewModel()
  var regEmail: String?
  var regPassword: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
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
      $0.title = "Tell us about yourself"
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
        $0.cell.valueTextField.text = appDelegate?.registerUser?.firstName
        self.viewModel.firstname.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Last name"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.lastname.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.lastName
        self.viewModel.lastname.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Mobile Number"
      $0.cell.height = { 80.0 }
      self.viewModel.mobNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.mobile
        self.viewModel.mobNo.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Alternate Contact Number"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.alternateMobNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.alternateMobile
        self.viewModel.alternateMobNo.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Designation"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.designation.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.designation
        self.viewModel.designation.value = $0.cell.valueTextField.text
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
        $0.cell.titleLabel.text = "Next up: Company details"
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.viewDidAppear?()
    }

}

extension REGBuyerPersonalInfoController: ButtonActionProtocol {
  func customButtonSelected(tag: Int) {
    switch tag {
    case 101:
      print("Next Selected")
      self.viewModel.nextSelected?()
    case 102:
        print("View FAQ")
        didTapFAQButton(tag: 1)
    default:
      print("do nothing")
    }
  }
}
