//
//  REGBuyerAddressInfoController.swift
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

class BuyerAddressViewModel {
  var addr1 = Observable<String?>(nil)
  var addr2 = Observable<String?>(nil)
  var street = Observable<String?>(nil)
  var city = Observable<String?>(nil)
  var state = Observable<String?>(nil)
  var country = Observable<String?>(nil)
  var pincode = Observable<String?>(nil)
  var landmark = Observable<String?>(nil)
  var nextSelected: (() -> Void)?
}

class REGBuyerAddressInfoController: FormViewController {
  
  var viewModel = BuyerAddressViewModel()
  
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
      $0.title = "What's your registered address?"
      $0.cellStyle = .default
      $0.cell.textLabel?.textAlignment = .center
      $0.cell.textLabel?.textColor = .darkGray
      $0.cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
      $0.cell.height = { 40.0 }
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Address Line 1"
      $0.cell.height = { 80.0 }
      self.viewModel.addr1.value = $0.cell.valueTextField.text
      self.viewModel.addr1.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Address Line 2"
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.height = { 80.0 }
      self.viewModel.addr2.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Street"
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.height = { 80.0 }
      self.viewModel.street.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Landmark"
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.height = { 80.0 }
      self.viewModel.landmark.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "City"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.city.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "State"
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.state.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
    }
      <<< ActionSheetRow() {
        $0.title = "Country"
        $0.cell.height = { 80.0 }
        $0.options = ["India", "USA", "Spain"]
      }.onChange({ (actionsheet) in
        self.viewModel.country.value = actionsheet.value ?? "India"
      }).cellUpdate({ (str, row) in
        let attrstr = NSMutableAttributedString(string: "Country *", attributes:[NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        attrstr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: attrstr.length - 1,length:1))
        row.cell.textLabel?.attributedText = attrstr
      })
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Pincode"
        $0.cell.height = { 80.0 }
        self.viewModel.pincode.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
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

}

extension REGBuyerAddressInfoController: ButtonActionProtocol {
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

