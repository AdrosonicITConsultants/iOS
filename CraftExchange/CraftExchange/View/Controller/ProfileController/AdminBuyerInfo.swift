//
//  AdminBuyerInfo.swift
//  CraftExchange
//
//  Created by Kiran Songire on 23/10/20.
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

class AdminBuyerInfoViewModel {
    
}

class AdminBuyerInfo: FormViewController{
    
    var isEditable = false
    var viewModel = AdminBankDetailsViewModel()
    var userObject: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black
        var addressString = ""
        userObject?.paymentAccountList .forEach({ (account) in
            if account.accType == 1 {
                addressString = account.AccNoUpiMobile ?? ""
            }
        })
        
        self.view.backgroundColor = .white
        form +++
            Section()
            <<< LabelUnderlinedRow() {
                $0.tag = "Point of Contact"
                $0.cell.height = { 80.0 }
                $0.cell.LabelHeader.text = " Point of Contact"
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "Name1"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = "\(userObject?.pointOfContact.first?.pocFirstName ?? "") \(userObject?.pointOfContact.first?.pocLastName ?? "")"
                $0.cell.valueTextField.textColor = .white
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
                $0.tag = "Email Id-1"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = userObject?.pointOfContact.first?.pocEmail ?? ""
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
                $0.tag = "Mobile Number-1"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = userObject?.pointOfContact.first?.pocContantNo ?? ""
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
                       
            <<< LabelUnderlinedRow() {
                $0.tag = "Brand Details"
                $0.cell.height = { 80.0 }
                $0.cell.LabelHeader.text = " Brand Details"
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "GSTNO"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = userObject?.buyerCompanyDetails.first?.gstNo ?? ""
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "GST Number".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "CIN-No"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = userObject?.buyerCompanyDetails.first?.cin ?? ""
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "CIN Number".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "PAN"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = userObject?.pancard ?? ""
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "PAN Number".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
        
        <<< LabelUnderlinedRow() {
            $0.tag = "Contact Details"
            $0.cell.height = { 80.0 }
            $0.cell.LabelHeader.text = " Contact Details"
        }
        <<< RoundedTextFieldRow() {
            $0.tag = "Email Id-2"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.valueTextField.isUserInteractionEnabled = false
            $0.cell.backgroundColor = .black
            $0.cell.valueTextField.text = userObject?.email ?? ""
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
            $0.tag = "Mobile Number-2"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.valueTextField.isUserInteractionEnabled = false
            $0.cell.backgroundColor = .black
            $0.cell.valueTextField.text = userObject?.mobile ?? ""
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
            $0.tag = "Mobile Number-3"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.valueTextField.isUserInteractionEnabled = false
            $0.cell.backgroundColor = .black
            $0.cell.valueTextField.text = userObject?.alternateMobile ?? ""
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
        <<< LabelUnderlinedRow() {
           $0.tag = "Website Details"
           $0.cell.height = { 80.0 }
           $0.cell.LabelHeader.text = " Website Details"
       }
        <<< RoundedTextFieldRow() {
            $0.tag = "WebsiteLink"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.valueTextField.isUserInteractionEnabled = false
            $0.cell.backgroundColor = .black
            $0.cell.valueTextField.text = "\(userObject?.websiteLink ?? "")"
            $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
            $0.cell.valueTextField.leftPadding = 0
            $0.cell.isUserInteractionEnabled = false
        }.cellUpdate({ (cell, row) in
            cell.titleLabel.text = "WebsiteLink".localized
            cell.titleLabel.textColor = .white
            cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
            cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
        })
        <<< RoundedTextFieldRow() {
           $0.tag = "SocialLink"
           $0.cell.height = { 80.0 }
           $0.cell.compulsoryIcon.isHidden = true
           $0.cell.valueTextField.isUserInteractionEnabled = false
           $0.cell.backgroundColor = .black
           $0.cell.valueTextField.text = "\(userObject?.socialMediaLink ?? "")"
           $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
           $0.cell.valueTextField.leftPadding = 0
           $0.cell.isUserInteractionEnabled = false
       }.cellUpdate({ (cell, row) in
           cell.titleLabel.text = "SocialLink".localized
           cell.titleLabel.textColor = .white
           cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
           cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
       })
        <<< LabelUnderlinedRow() {
          $0.tag = "Delivery Details"
          $0.cell.height = { 80.0 }
          $0.cell.LabelHeader.text = " Delivery Details"
      }
        <<< RoundedTextFieldRow() {
            $0.tag = "Details"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.valueTextField.isUserInteractionEnabled = false
            $0.cell.backgroundColor = .black
            $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
            $0.cell.valueTextField.leftPadding = 0
            $0.cell.isUserInteractionEnabled = false
            var addressString = ""
            userObject?.addressList .forEach({ (account) in
                if account.addressType?.addrType == "Delivery" {
                    addressString = account.addressString
                }
            })
            $0.cell.valueTextField.text = addressString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Details".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
        })
}
}


