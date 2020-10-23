//
//  AdminGeneralInfo.swift
//  CraftExchange
//
//  Created by Kiran Songire on 22/10/20.
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
import ImageRow

class AdminGeneralInfoViewModel {
}

class AdminGeneralInfo: FormViewController {
    
    var editEnabled = false
    var viewModel = AdminGeneralInfoViewModel()
    var allCountries: Results<Country>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black

        let realm = try! Realm()
        form +++
            Section()
           
            <<< RoundedTextFieldRow() {
                $0.tag = "Name"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = "\(User.loggedIn()?.firstName ?? "") \(User.loggedIn()?.lastName ?? "")"
                $0.cell.valueTextField.textColor = .white
                $0.cell.valueTextField.text = "Surya Gupta"
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Name".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Email Id"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = User.loggedIn()?.email ?? ""
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Email Id".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Mobile Number"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                 $0.cell.valueTextField.text = "8776655434"
//                $0.cell.valueTextField.text = User.loggedIn()?.mobile ?? ""
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Mobile Number".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
           <<< RoundedTextFieldRow() {
               $0.tag = "Address:"
               $0.cell.height = { 80.0 }
               $0.cell.compulsoryIcon.isHidden = true
               $0.cell.valueTextField.isUserInteractionEnabled = false
               $0.cell.backgroundColor = .black
               $0.cell.valueTextField.text = "30b, Royal Park Behind hdfc"
               $0.cell.valueTextField.textColor = .white
//               $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
               $0.cell.valueTextField.leftPadding = 0
               $0.cell.isUserInteractionEnabled = false
           }.cellUpdate({ (cell, row) in
               cell.titleLabel.text = "Address: ".localized
               cell.titleLabel.textColor = .white
               cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
               cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
           })
            <<< RoundedTextFieldRow() {
                $0.tag = "Details"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                 $0.cell.valueTextField.text = "Excellent!!!!!!"
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Details".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
           
    }
    
    
    
    
}

