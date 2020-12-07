//
//  BuyerGeneralInfo.swift
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

class BuyerGeneralInfo: FormViewController {
    var isEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditing), name: Notification.Name("EnableEditNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableEditing), name: Notification.Name("DisableEditNotification"), object: nil)
        self.view.backgroundColor = .white
        let parentVC = self.parent as! BuyerProfileController
        
        form +++
            Section()
            <<< RoundedTextFieldRow() {
                $0.tag = "Designation"
                $0.cell.titleLabel.text = "Designation".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.designation ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                parentVC.viewModel.designation.value = $0.cell.valueTextField.text
                parentVC.viewModel.designation.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.height = { 80.0 }
            }.cellUpdate({ (cell, row) in
                parentVC.viewModel.designation.value = cell.valueTextField.text
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
                $0.cell.height = { 80.0 }
                $0.title = "Registered Address".localized
            }.cellUpdate({ (cell, row) in
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.addressString
                    }
                })
                cell.detailTextLabel?.text = addressString
                cell.detailTextLabel?.numberOfLines = 10
                cell.detailTextLabel?.font = .systemFont(ofSize: 10)
            })
            <<< LabelRow() {
                $0.title = User.loggedIn()?.email ?? ""
                $0.cellStyle = .default
                $0.cell.height = { 40.0 }
                $0.cell.imageView?.image = UIImage(named: "emailIcon")
                $0.cell.imageView?.tintColor = .darkGray
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .darkGray
            })
            <<< LabelRow() { row in
                row.title = "\(User.loggedIn()?.mobile ?? "") (primary)"
                row.cell.imageView?.image = UIImage(named: "phoneIcon")
                row.cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
                row.cell.height = { 40.0 }
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .darkGray
            })
            <<< RoundedTextFieldRow("alternateMobile") {
                $0.tag = "alternateMobile"
                $0.cell.titleLabel.text = "Alternate Mobile".localized
                $0.cell.compulsoryIcon.isHidden = true
                $0.cellStyle = .default
                $0.cell.valueTextField.text = User.loggedIn()?.alternateMobile ?? ""
                $0.cell.valueTextField.leftImage = UIImage.init(named: "phoneIcon")
                $0.cell.valueTextField.leftImage?.withTintColor(.gray)
            }.cellUpdate({ (cell, row) in
                parentVC.viewModel.alternateMobile.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                    cell.isHidden = false
                    cell.height = { 80.0 }
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                    if User.loggedIn()?.alternateMobile != nil && User.loggedIn()?.alternateMobile != "" {
                        cell.isHidden = false
                        cell.height = { 80.0 }
                    }else {
                        cell.isHidden = true
                        cell.height = { 0.0 }
                    }
                }
            })
            <<< LabelRow() { row in
                row.cell.height = { 300.0 }
        }
    }
    
    @objc func enableEditing() {
        self.view.backgroundColor = .lightGray
        isEditable = true
        for row in self.form.allRows {
            if row.tag == "Designation" || row.tag == "alternateMobile" {
                row.updateCell()
            }
        }
    }
    
    @objc func disableEditing() {
        isEditable = false
        for row in self.form.allRows {
            if row.tag == "Designation" || row.tag == "alternateMobile" {
                row.updateCell()
            }
        }
    }
}
