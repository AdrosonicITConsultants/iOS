//
//  ArtisanBankDetails.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
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

class ArtisanBankDetailsViewModel {
    var accNo = Observable<String?>(nil)
    var bankName = Observable<String?>(nil)
    var benficiaryName = Observable<String?>(nil)
    var branchName = Observable<String?>(nil)
    var ifsc = Observable<String?>(nil)
    var gpayId = Observable<String?>(nil)
    var paytm = Observable<String?>(nil)
}

class ArtisanBankDetails: FormViewController, ButtonActionProtocol {
    
    var isEditable = false
    var viewModel = ArtisanBankDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        var addressString = ""
        User.loggedIn()?.paymentAccountList .forEach({ (account) in
            if account.accType == 1 {
                addressString = account.AccNoUpiMobile ?? ""
            }
        })
        
        self.view.backgroundColor = .white
        form +++
            Section()
            <<< LabelRow() {
                $0.tag = "Section1"
                $0.cell.height = { 60.0 }
                $0.title = "Bank Details".localized
                $0.cell.isUserInteractionEnabled = false
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "AccNo"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                User.loggedIn()?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                self.viewModel.accNo.value = $0.cell.valueTextField.text
                self.viewModel.accNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Account Number".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.accNo.value = cell.valueTextField.text
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
                $0.tag = "BankName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                User.loggedIn()?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.bankName ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                self.viewModel.bankName.value = $0.cell.valueTextField.text
                self.viewModel.bankName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Bank Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.bankName.value = cell.valueTextField.text
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
                $0.tag = "BenefitiaryName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                User.loggedIn()?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.name ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                self.viewModel.benficiaryName.value = $0.cell.valueTextField.text
                self.viewModel.benficiaryName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Benefitiary Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.benficiaryName.value = cell.valueTextField.text
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
                $0.tag = "BranchName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                User.loggedIn()?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.branchName ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                self.viewModel.branchName.value = $0.cell.valueTextField.text
                self.viewModel.branchName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Branch Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.branchName.value = cell.valueTextField.text
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
                $0.tag = "Ifsc"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                User.loggedIn()?.paymentAccountList .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.ifsc ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
                self.viewModel.ifsc.value = $0.cell.valueTextField.text
                self.viewModel.ifsc.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "IFSC Code".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.ifsc.value = cell.valueTextField.text
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
                $0.tag = "Section2"
                $0.cell.height = { 60.0 }
                $0.title = "Digital Payment Details".localized
                $0.cell.isUserInteractionEnabled = false
            }
            <<< TextRow() {
                $0.tag = "gpay"
                $0.cell.height = { 60.0 }
                $0.title = "Google Pay".localized
                $0.cell.imageView?.image = UIImage.init(named: "gPayIcon")
                self.viewModel.gpayId.value = $0.cell.textField.text
                self.viewModel.gpayId.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                self.viewModel.gpayId.value = cell.textField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.textField.isUserInteractionEnabled = true
                    cell.textField.layer.borderColor = UIColor.black.cgColor
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.textField.isUserInteractionEnabled = false
                    cell.textField.layer.borderColor = UIColor.white.cgColor
                    var valueString = ""
                    User.loggedIn()?.paymentAccountList .forEach({ (account) in
                        if account.accType == 2 {
                            valueString = account.AccNoUpiMobile ?? ""
                        }
                    })
                    cell.textField.text = valueString
                }
            })
            <<< TextRow() {
                $0.tag = "paytm"
                $0.cell.height = { 60.0 }
                $0.title = "Paytm".localized
                $0.cell.imageView?.image = UIImage.init(named: "paytmIcon")
                self.viewModel.paytm.value = $0.cell.textField.text
                self.viewModel.paytm.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                self.viewModel.paytm.value = cell.textField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.textField.isUserInteractionEnabled = true
                    cell.textField.layer.borderColor = UIColor.black.cgColor
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.textField.isUserInteractionEnabled = false
                    cell.textField.layer.borderColor = UIColor.white.cgColor
                    var valueString = ""
                    User.loggedIn()?.paymentAccountList .forEach({ (account) in
                        if account.accType == 4 {
                            valueString = account.AccNoUpiMobile ?? ""
                        }
                    })
                    cell.textField.text = valueString
                }
            })
            <<< RoundedButtonViewRow("EditArtisanBankDetails") {
                $0.tag = "EditArtisanBankDetails"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = .black
                $0.cell.buttonView.backgroundColor = .black
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Edit bank details".localized, for: .normal)
                $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = 101
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
            }
            <<< LabelRow() { row in
                row.cell.height = { 300.0 }
            }
    }
    
    func customButtonSelected(tag: Int) {
        //Edit selected
        let btnRow = self.form.rowBy(tag: "EditArtisanBankDetails") as? RoundedButtonViewRow
        if btnRow?.cell.buttonView.titleLabel?.text == "Edit bank details".localized {
            isEditable = true
            btnRow?.cell.buttonView.setTitle("Save bank details".localized, for: .normal)
            btnRow?.cell.buttonView.borderColour = .red
            btnRow?.cell.buttonView.backgroundColor = .red
        }else {
            isEditable = false
            btnRow?.cell.buttonView.setTitle("Edit bank details".localized, for: .normal)
            btnRow?.cell.buttonView.borderColour = .black
            btnRow?.cell.buttonView.backgroundColor = .black
            if let parentVC = self.parent as? BuyerProfileController {
                var finalJson: [[String: Any]]?
                let newBankDetails = bankDetails.init(id: 0, accNo: self.viewModel.accNo.value, accType: (accId: 1, accDesc: "bank"), bankName: self.viewModel.bankName.value, branchName: self.viewModel.branchName.value, ifsc: self.viewModel.ifsc.value, name: self.viewModel.benficiaryName.value)
                finalJson = [newBankDetails.toJSON()]
                if self.viewModel.gpayId.value != "" {
                    let newBankDetails = bankDetails.init(id: 0, accNo: self.viewModel.gpayId.value, accType: (accId: 2, accDesc: "gpay"), bankName: nil, branchName: nil, ifsc: nil, name: nil)
                    finalJson?.append(newBankDetails.toJSON())
                }
                if self.viewModel.paytm.value != "" {
                    let newBankDetails = bankDetails.init(id: 0, accNo: self.viewModel.paytm.value, accType: (accId: 4, accDesc: "paytm"), bankName: nil, branchName: nil, ifsc: nil, name: nil)
                    finalJson?.append(newBankDetails.toJSON())
                }
                if let _ = finalJson {
                    parentVC.viewModel.updateArtisanBankDetails?(finalJson!)
                }
            }
        }
        for row in self.form.allRows {
            if row.tag != "Section2" && row.tag != "Section1" {
                row.updateCell()
            }
        }
    }
}



