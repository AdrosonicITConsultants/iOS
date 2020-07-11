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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditing), name: Notification.Name("EnableEditNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableEditing), name: Notification.Name("DisableEditNotification"), object: nil)
        self.view.backgroundColor = .white
        form +++
            Section()
            <<< RoundedTextFieldRow() {
                $0.tag = "Designation"
                $0.cell.titleLabel.text = "Designation".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.height = { 60.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.designation ?? "Designation"
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }
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
                $0.cellStyle = .default
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.valueTextField.text = "\(User.loggedIn()?.alternateMobile ?? "") (alternate)"
                $0.cell.valueTextField.leftImage = UIImage.init(named: "phoneIcon")
                $0.cell.valueTextField.leftImage?.withTintColor(.gray)
                if User.loggedIn()?.alternateMobile != nil && User.loggedIn()?.alternateMobile != "" {
                    $0.cell.isHidden = false
                    $0.cell.height = { 40.0 }
                }else {
                    $0.cell.isHidden = true
                    $0.cell.height = { 0.0 }
                }
                $0.cell.isUserInteractionEnabled = false
            }
            <<< LabelRow() { row in
                row.cell.height = { 300.0 }
            }
    }
    
    @objc func enableEditing() {
        self.view.backgroundColor = .lightGray
        let designationRow = self.form.rowBy(tag: "Designation") as? RoundedTextFieldRow
        designationRow?.cell.valueTextField.isUserInteractionEnabled = true
        let alternateMobile = self.form.rowBy(tag: "alternateMobile") as? RoundedTextFieldRow
        alternateMobile?.cell.valueTextField.isUserInteractionEnabled = true
    }
    
    @objc func disableEditing() {
        let designationRow = self.form.rowBy(tag: "Designation") as? RoundedTextFieldRow
        designationRow?.cell.valueTextField.isUserInteractionEnabled = false
        let alternateMobile = self.form.rowBy(tag: "alternateMobile") as? RoundedTextFieldRow
        alternateMobile?.cell.valueTextField.isUserInteractionEnabled = false
    }
    
    @objc func saveProfileUpdate() {
        print("save profile changes")
        NotificationCenter.default.post(name: Notification.Name("DisableEditNotification"), object: nil)
    }
}
