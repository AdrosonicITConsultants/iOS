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
import ImageRow

class BuyerCompanyViewModel {
  var companyName = Observable<String?>(nil)
  var gstNo = Observable<String?>(nil)
  var cinNo = Observable<String?>(nil)
  var panNo = Observable<String?>(nil)
  var pocFirstName = Observable<String?>(nil)
  var pocMobNo = Observable<String?>(nil)
  var pocEmailId = Observable<String?>(nil)
  var brandLogo = Observable<Data?>(nil)
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
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
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
        $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerCompanyDetails?.companyName
        self.viewModel.companyName.value = $0.cell.valueTextField.text
      }
        <<< ImageRow() { row in
            row.title = "Upload your brand logo".localized
            row.sourceTypes = [.Camera, .PhotoLibrary, .SavedPhotosAlbum]
            row.clearAction = .yes(style: UIAlertAction.Style.destructive)
        }.onChange({ (row) in
            if let image = row.value {
                var imgData: Data?
                if let data = image.pngData() {
                    imgData = data
                } else if let data = image.jpegData(compressionQuality: 1) {
                    imgData = data
                }
                self.viewModel.brandLogo.value = imgData
            }
        })
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "GST Number".localized
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.gstNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerCompanyDetails?.gstNo
        self.viewModel.gstNo.value = $0.cell.valueTextField.text
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "CIN Number".localized
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.cinNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerCompanyDetails?.cin
        self.viewModel.cinNo.value = $0.cell.valueTextField.text
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "PAN Number".localized
        $0.cell.valueTextField.autocapitalizationType = .allCharacters
        $0.cell.height = { 80.0 }
        self.viewModel.panNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.pancard
        self.viewModel.panNo.value = $0.cell.valueTextField.text
      }
      <<< LabelRow() {
        $0.title = "Point of Contact Details".localized
        $0.cell.height = { 80.0 }
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Name".localized
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.pocFirstName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerPointOfContact?.firstName
        self.viewModel.pocFirstName.value = $0.cell.valueTextField.text
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Email Address".localized
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.pocEmailId.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerPointOfContact?.email
        self.viewModel.pocEmailId.value = $0.cell.valueTextField.text
      }
      <<< RoundedTextFieldRow() {
        $0.cell.titleLabel.text = "Mobile Number".localized
        $0.cell.height = { 80.0 }
        $0.cell.compulsoryIcon.isHidden = true
        self.viewModel.pocMobNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerPointOfContact?.contactNo
        self.viewModel.pocMobNo.value = $0.cell.valueTextField.text
      }
      <<< RoundedButtonViewRow("REGNextCell") {
        $0.cell.titleLabel.text = "Fields are mandatory".localized
        $0.cell.compulsoryIcon.isHidden = false
        $0.cell.greyLineView.isHidden = false
        $0.cell.buttonView.borderColour = .black
        $0.cell.buttonView.backgroundColor = .black
        $0.cell.buttonView.setTitleColor(.white, for: .normal)
        $0.cell.buttonView.setTitle("Next".localized, for: .normal)
        $0.cell.tag = 101
        $0.cell.delegate = self
        $0.cell.height = { 100.0 }
    }
      <<< RoundedButtonViewRow("REGHelpCell") {
        $0.cell.titleLabel.text = "Next up: Address details".localized
          $0.cell.compulsoryIcon.isHidden = true
          $0.cell.greyLineView.isHidden = true
          $0.cell.buttonView.borderColour = .white
          $0.cell.buttonView.backgroundColor = .white
          $0.cell.buttonView.setTitleColor(.lightGray, for: .normal)
          $0.cell.buttonView.setTitle("Privacy Policy".localized, for: .normal)
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
    case 102:
        print("View FAQ")
        didTapFAQButton(tag: 1)
    default:
      print("do nothing")
    }
  }
}
