//
//  BuyerCompanyProfileInfo.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm

class BuyerCompanyProfileInfo: FormViewController {
    
    var isEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let parentVC = self.parent as! BuyerProfileController
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditing), name: Notification.Name("EnableEditNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableEditing), name: Notification.Name("DisableEditNotification"), object: nil)
        
        self.form +++
          Section()
            <<< RoundedTextFieldRow() {
                $0.tag = "GST"
                $0.cell.titleLabel.text = "GST Number".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.buyerCompanyDetails.first?.gstNo ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
                parentVC.viewModel.gst.value = $0.cell.valueTextField.text
                parentVC.viewModel.gst.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.gst.value = cell.valueTextField.text
                    if self.isEditable {
                        cell.isUserInteractionEnabled = true
                        cell.valueTextField.isUserInteractionEnabled = true
                        cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                        cell.valueTextField.leftPadding = 10
                    }else {
                        cell.isUserInteractionEnabled = false
                        cell.valueTextField.isUserInteractionEnabled = false
                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                        cell.valueTextField.leftPadding = 0
                    }
                })
            <<< RoundedTextFieldRow() {
                $0.tag = "CIN"
                $0.cell.titleLabel.text = "CIN Number".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.buyerCompanyDetails.first?.cin ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
                parentVC.viewModel.cin.value = $0.cell.valueTextField.text
                parentVC.viewModel.cin.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.cin.value = cell.valueTextField.text
                    if self.isEditable {
                        cell.isUserInteractionEnabled = true
                        cell.valueTextField.isUserInteractionEnabled = true
                        cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                        cell.valueTextField.leftPadding = 10
                    }else {
                        cell.isUserInteractionEnabled = false
                        cell.valueTextField.isUserInteractionEnabled = false
                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                        cell.valueTextField.leftPadding = 0
                    }
                })
            <<< RoundedTextFieldRow() {
                $0.tag = "PAN"
                $0.cell.titleLabel.text = "PAN".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.pancard ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
                parentVC.viewModel.pancard.value = $0.cell.valueTextField.text
                parentVC.viewModel.pancard.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.autocapitalizationType = .allCharacters
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.pancard.value = cell.valueTextField.text
                    if self.isEditable {
                        cell.isUserInteractionEnabled = true
                        cell.valueTextField.isUserInteractionEnabled = true
                        cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                        cell.valueTextField.leftPadding = 10
                    }else {
                        cell.isUserInteractionEnabled = false
                        cell.valueTextField.isUserInteractionEnabled = false
                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                        cell.valueTextField.leftPadding = 0
                    }
                })
            <<< LabelRow() {
                $0.cell.height = { 60.0 }
                $0.title = "Details for Point of Contact".localized
                $0.cell.isUserInteractionEnabled = false
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "PocName"
                $0.cell.titleLabel.text = "Name".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = "\(User.loggedIn()?.pointOfContact.first?.pocFirstName ?? "") \(User.loggedIn()?.pointOfContact.first?.pocLastName ?? "")"
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
                parentVC.viewModel.pocFirstName.value = $0.cell.valueTextField.text
                parentVC.viewModel.pocFirstName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.pocFirstName.value = cell.valueTextField.text
                    if self.isEditable {
                        cell.isUserInteractionEnabled = true
                        cell.valueTextField.isUserInteractionEnabled = true
                        cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                        cell.valueTextField.leftPadding = 10
                    }else {
                        cell.isUserInteractionEnabled = false
                        cell.valueTextField.isUserInteractionEnabled = false
                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                        cell.valueTextField.leftPadding = 0
                    }
                })
            <<< RoundedTextFieldRow() {
                $0.tag = "PocMobile"
                $0.cell.titleLabel.text = "Mobile Number".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.height = { 80.0 }
                $0.cell.valueTextField.text = User.loggedIn()?.pointOfContact.first?.pocContantNo ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                parentVC.viewModel.pocContact.value = $0.cell.valueTextField.text
                parentVC.viewModel.pocContact.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.pocContact.value = cell.valueTextField.text
                    if self.isEditable {
                        cell.isUserInteractionEnabled = true
                        cell.valueTextField.isUserInteractionEnabled = true
                        cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                        cell.valueTextField.leftPadding = 10
                    }else {
                        cell.isUserInteractionEnabled = false
                        cell.valueTextField.isUserInteractionEnabled = false
                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                        cell.valueTextField.leftPadding = 0
                    }
                })
            <<< RoundedTextFieldRow() {
                $0.tag = "PocEmail"
                $0.cell.titleLabel.text = "Email Id".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.pointOfContact.first?.pocEmail ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
                parentVC.viewModel.pocEmail.value = $0.cell.valueTextField.text
                parentVC.viewModel.pocEmail.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.pocEmail.value = cell.valueTextField.text
                    if self.isEditable {
                        cell.isUserInteractionEnabled = true
                        cell.valueTextField.isUserInteractionEnabled = true
                        cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                        cell.valueTextField.leftPadding = 10
                    }else {
                        cell.isUserInteractionEnabled = false
                        cell.valueTextField.isUserInteractionEnabled = false
                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                        cell.valueTextField.leftPadding = 0
                    }
                })
        
    }
    
    @objc func enableEditing() {
        self.view.backgroundColor = .lightGray
        isEditable = true
        for row in self.form.allRows {
            row.updateCell()
        }
    }
    
    @objc func disableEditing() {
        isEditable = false
        for row in self.form.allRows {
            row.updateCell()
        }
    }
}
