//
//  AdminBankDetails.swift
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

class AdminBankDetailsViewModel {
    
}

class AdminBankDetails: FormViewController{
    
    var isEditable = false
    var viewModel = AdminBankDetailsViewModel()
    var userObject: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black
        self.view.backgroundColor = .white
        form +++
            Section()
            <<< RoundedTextFieldRow() {
                $0.tag = "AccNo"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.textColor = .white
                var valueString = ""
                userObject?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                //                self.viewModel.accNo.value = $0.cell.valueTextField.text
                //                self.viewModel.accNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Account Number".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                //                self.viewModel.accNo.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
//                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "BenefitiaryName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.textColor = .white
                var valueString = ""
                userObject?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.name ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                //                           self.viewModel.benficiaryName.value = $0.cell.valueTextField.text
                //                           self.viewModel.benficiaryName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Benefitiary Name".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                //                           self.viewModel.benficiaryName.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                    //                               cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "BankName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.textColor = .white
                var valueString = ""
                userObject?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.bankName ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                //                self.viewModel.bankName.value = $0.cell.valueTextField.text
                //                self.viewModel.bankName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Bank Name".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                //                self.viewModel.bankName.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                    //                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "BranchName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.textColor = .white
                var valueString = ""
                userObject?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.branchName ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Branch Name".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                //                self.viewModel.branchName.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                    //                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
        
        <<< RoundedTextFieldRow() {
            $0.tag = "IFSCCode"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.backgroundColor = .black
            $0.cell.valueTextField.textColor = .white
            var valueString = ""
            userObject?.paymentAccountList .forEach({ (account) in
                if account.accType == 1 {
                    valueString = account.ifsc ?? ""
                }
            })
            $0.cell.valueTextField.text = valueString
        }.cellUpdate({ (cell, row) in
            cell.titleLabel.text = "IFSC Code".localized
            cell.titleLabel.textColor = .white
            cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
            cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            cell.isUserInteractionEnabled = false
            cell.valueTextField.isUserInteractionEnabled = false
            cell.valueTextField.leftPadding = 0
        })
            <<< LabelRow() {
                $0.tag = "OtherDetails"
                $0.cell.height = { 60.0 }
                $0.cell.backgroundColor = .black
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.text = "Digital Payment Details".localized
                cell.textLabel?.textColor = .white
                cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            })
        <<< TextRow() {
            $0.tag = "gpay"
            $0.cell.height = { 60.0 }
            $0.title = "Google Pay".localized
            $0.cell.imageView?.image = UIImage.init(named: "gPayIcon")
            $0.cell.backgroundColor = .black
        }.cellUpdate({ (cell, row) in
            cell.isUserInteractionEnabled = false
            cell.textField.isUserInteractionEnabled = false
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            cell.textField.textColor = .white
            cell.textField.font = .systemFont(ofSize: 16, weight: .regular)
            var valueString = ""
            self.userObject?.paymentAccountList .forEach({ (account) in
                if account.accType == 2 {
                    valueString = account.AccNoUpiMobile ?? ""
                }
            })
            cell.textField.text = valueString
        })
        <<< TextRow() {
            $0.tag = "paytm"
            $0.cell.height = { 60.0 }
            $0.title = "Paytm".localized
            $0.cell.backgroundColor = .black
            $0.cell.imageView?.image = UIImage.init(named: "paytmIcon")
        }.cellUpdate({ (cell, row) in
            cell.isUserInteractionEnabled = false
            cell.textField.isUserInteractionEnabled = false
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            cell.textField.textColor = .white
            cell.textField.font = .systemFont(ofSize: 16, weight: .regular)
            var valueString = ""
            self.userObject?.paymentAccountList .forEach({ (account) in
                if account.accType == 4 {
                    valueString = account.AccNoUpiMobile ?? ""
                }
            })
            cell.textField.text = valueString
        })
        <<< TextRow() {
            $0.tag = "phonepay"
            $0.cell.height = { 60.0 }
            $0.title = "Phone Pay".localized
            $0.cell.backgroundColor = .black
            $0.cell.imageView?.image = UIImage.init(named: "phone-pe")
        }.cellUpdate({ (cell, row) in
            cell.isUserInteractionEnabled = false
            cell.textField.isUserInteractionEnabled = false
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            cell.textField.textColor = .white
            cell.textField.font = .systemFont(ofSize: 16, weight: .regular)
            var valueString = ""
            self.userObject?.paymentAccountList .forEach({ (account) in
                if account.accType == 3 {
                    valueString = account.AccNoUpiMobile ?? ""
                }
            })
            cell.textField.text = valueString
        })
    }
}



