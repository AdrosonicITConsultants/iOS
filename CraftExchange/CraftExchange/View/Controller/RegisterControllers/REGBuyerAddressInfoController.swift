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
import Realm
import RealmSwift
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
    var allCountries: Results<Country>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = roleBarButton()
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let realm = try! Realm()
        allCountries = realm.objects(Country.self).sorted(byKeyPath: "entityID")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.form +++
            Section()
            <<< LabelRow() {
                $0.cell.height = { 220.0 }
                $0.cell.imageView?.frame = $0.cell.contentView.frame
                $0.cell.imageView?.image = UIImage(named: "logo-underlying-text")
            }
            <<< LabelRow() {
                $0.title = "What's your registered address?".localized
                $0.cellStyle = .default
                $0.cell.textLabel?.textAlignment = .center
                $0.cell.textLabel?.textColor = .darkGray
                $0.cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                $0.cell.height = { 40.0 }
            }
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "Address Line 1".localized
                $0.cell.height = { 80.0 }
                self.viewModel.addr1.value = $0.cell.valueTextField.text
                self.viewModel.addr1.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.line1
                self.viewModel.addr1.value = $0.cell.valueTextField.text
            }
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "Address Line 2".localized
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.height = { 80.0 }
                self.viewModel.addr2.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.line2
                self.viewModel.addr2.value = $0.cell.valueTextField.text
            }
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "Street".localized
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.height = { 80.0 }
                self.viewModel.street.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.street
                self.viewModel.street.value = $0.cell.valueTextField.text
            }
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "Landmark".localized
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.height = { 80.0 }
                self.viewModel.landmark.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.landmark
                self.viewModel.landmark.value = $0.cell.valueTextField.text
            }
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "City".localized
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                self.viewModel.city.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.city
                self.viewModel.city.value = $0.cell.valueTextField.text
            }
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "State".localized
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                self.viewModel.state.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.state
                self.viewModel.state.value = $0.cell.valueTextField.text
            }
            <<< ActionSheetRow() {
                $0.title = "Country"
                $0.cell.height = { 80.0 }
                $0.options = allCountries?.compactMap { $0.name }
            }.onChange({ (actionsheet) in
                self.viewModel.country.value = actionsheet.value ?? "India"
            }).cellUpdate({ (str, row) in
                let attrstr = NSMutableAttributedString(string: "Country *", attributes:[NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                attrstr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: attrstr.length - 1,length:1))
                row.cell.textLabel?.attributedText = attrstr
            })
            <<< RoundedTextFieldRow() {
                $0.cell.titleLabel.text = "Pincode".localized
                $0.cell.height = { 80.0 }
                self.viewModel.pincode.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.pincode
                self.viewModel.pincode.value = $0.cell.valueTextField.text
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
                $0.cell.titleLabel.text = "Next up: Company details".localized
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

extension REGBuyerAddressInfoController: ButtonActionProtocol {
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
