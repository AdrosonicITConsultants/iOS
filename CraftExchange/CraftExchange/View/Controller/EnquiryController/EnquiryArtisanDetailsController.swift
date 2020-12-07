//
//  EnquiryArtisanDetailsController.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/09/20.
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

class EnquiryArtisanDetailsController: FormViewController {
    
    var enquiryObject: Enquiry?
    var orderObject: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let realm = try? Realm()
        let accountDetails = realm?.objects(PaymentAccDetails.self).filter("%K == %@","userId",enquiryObject?.userId ?? orderObject?.userId ?? 0)
        
        let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        form +++
            Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                $0.cell.isUserInteractionEnabled = false
                $0.cell.actionButton.isUserInteractionEnabled = false
                if let name = self.enquiryObject?.logo ?? self.orderObject?.logo, let userID = self.enquiryObject?.userId ?? self.orderObject?.userId{
                    let url = URL(string: "\(KeychainManager.standard.imageBaseURL)/User/\(userID)/CompanyDetails/Logo/\(name)")
                    URLSession.shared.dataTask(with: url!) { data, response, error in
                        // do your stuff here...
                        DispatchQueue.main.async {
                            // do something on the main queue
                            if error == nil {
                                if let finalData = data {
                                    let row = self.form.rowBy(tag: "ProfileView") as? ProfileImageRow
                                    row?.cell.actionButton.setImage(UIImage.init(data: finalData), for: .normal)
                                }
                            }
                        }
                    }.resume()
                }
            }
            <<< LabelRow() {
                $0.title = enquiryObject?.brandName ?? orderObject?.brandName
            }
            <<< LabelRow() {
                if User.loggedIn()?.refRoleId == "2" {
                    $0.title = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? enquiryObject?.productCategoryHistoryId ?? orderObject?.productCategoryId ?? orderObject?.productCategoryHistoryId ?? 0)?.prodCatDescription ?? ""), \(enquiryObject?.clusterName ?? orderObject?.clusterName ?? "")"
                }else {
                    $0.title = "\(enquiryObject?.firstName ?? orderObject?.firstName ?? "") \(enquiryObject?.lastName ?? orderObject?.lastName ?? "")"
                }
            }
            <<< LabelRow() {
                if User.loggedIn()?.refRoleId == "2" {
                    $0.title = "\(enquiryObject?.firstName ?? orderObject?.firstName ?? "") \(enquiryObject?.lastName ?? orderObject?.lastName ?? "")"
                }else {
                    $0.title = enquiryObject?.email ?? orderObject?.email ?? ""
                }
            }
            <<< LabelRow() {
                if User.loggedIn()?.refRoleId == "2" {
                    $0.title = enquiryObject?.eqDescription ?? orderObject?.eqDescription
                }else {
                    $0.title = enquiryObject?.mobile ?? orderObject?.mobile
                }
            }
            <<< LabelRow() {
                $0.title = "Specialist in"
                var lbl = ""
                enquiryObject?.productCategories .forEach({ (catId) in
                    if catId == enquiryObject?.productCategories.last {
                        lbl.append("\(ProductCategory.getProductCat(catId: catId)?.prodCatDescription ?? "")")
                    }else {
                        lbl.append("\(ProductCategory.getProductCat(catId: catId)?.prodCatDescription ?? ""), ")
                    }
                })
                orderObject?.productCategories .forEach({ (catId) in
                    if catId == orderObject?.productCategories.last {
                        lbl.append("\(ProductCategory.getProductCat(catId: catId)?.prodCatDescription ?? "")")
                    }else {
                        lbl.append("\(ProductCategory.getProductCat(catId: catId)?.prodCatDescription ?? ""), ")
                    }
                })
                $0.value = lbl
                if User.loggedIn()?.refRoleId == "1" {
                    $0.hidden = true
                }
            }
            <<< SegmentedRow<String>() { row in
                row.title = ""
                if User.loggedIn()?.refRoleId == "1" {
                    row.options = ["Address Details".localized, "Other Details".localized]
                }else {
                    row.options = ["Bank Details".localized, "Digital Payment Details".localized]
                }
            }.onChange({ (row) in
                if User.loggedIn()?.refRoleId == "1" {
                    //Show Buyers Address and Other Details
                    
                    let digitalSection = self.form.sectionBy(tag: "DeliveryAddress")
                    let bankSection = self.form.sectionBy(tag: "OtherDetails")
                    if row.value == "Other Details" {
                        digitalSection?.hidden = true
                        digitalSection?.allRows .forEach({ (row) in
                            row.hidden = true
                            row.evaluateHidden()
                        })
                        bankSection?.hidden = false
                        bankSection?.allRows .forEach({ (row) in
                            row.hidden = false
                            row.evaluateHidden()
                        })
                    }else if row.value == "Address Details" {
                        digitalSection?.hidden = false
                        digitalSection?.allRows .forEach({ (row) in
                            row.hidden = false
                            row.evaluateHidden()
                        })
                        bankSection?.hidden = true
                        bankSection?.allRows .forEach({ (row) in
                            row.hidden = true
                            row.evaluateHidden()
                        })
                    }
                    digitalSection?.evaluateHidden()
                    bankSection?.evaluateHidden()
                }else {
                    //Show Artisans Bank Details
                    let digitalSection = self.form.sectionBy(tag: "DigitalPaymentSection")
                    let bankSection = self.form.sectionBy(tag: "BankSection")
                    if row.value == "Bank Details" {
                        digitalSection?.hidden = true
                        digitalSection?.allRows .forEach({ (row) in
                            row.hidden = true
                            row.evaluateHidden()
                        })
                        bankSection?.hidden = false
                        bankSection?.allRows .forEach({ (row) in
                            row.hidden = false
                            row.evaluateHidden()
                        })
                    }else if row.value == "Digital Payment Details" {
                        digitalSection?.hidden = false
                        digitalSection?.allRows .forEach({ (row) in
                            row.hidden = false
                            row.evaluateHidden()
                        })
                        bankSection?.hidden = true
                        bankSection?.allRows .forEach({ (row) in
                            row.hidden = true
                            row.evaluateHidden()
                        })
                    }
                    digitalSection?.evaluateHidden()
                    bankSection?.evaluateHidden()
                }
                
            })
            +++ Section() {section in
                section.tag = "BankSection"
                if User.loggedIn()?.refRoleId == "1" {
                    section.hidden = true
                }
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "AccNo"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Account Number".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "BankName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.bankName ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Bank Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "BenefitiaryName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.name ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Benefitiary Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "BranchName"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.branchName ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Branch Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Ifsc"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        valueString = account.ifsc ?? ""
                    }
                })
                $0.cell.valueTextField.text = valueString
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "IFSC Code".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            +++ Section(){ section in
                section.tag = "DigitalPaymentSection"
                section.hidden = true
            }
            <<< TextRow() {
                $0.tag = "gpay"
                $0.cell.height = { 60.0 }
                $0.title = "Google Pay".localized
                $0.cell.imageView?.image = UIImage.init(named: "gPayIcon")
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.isUserInteractionEnabled = false
                cell.textField.layer.borderColor = UIColor.white.cgColor
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
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
                $0.cell.imageView?.image = UIImage.init(named: "paytmIcon")
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.isUserInteractionEnabled = false
                cell.textField.layer.borderColor = UIColor.white.cgColor
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
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
                $0.cell.imageView?.image = UIImage.init(named: "phone-pe")
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.isUserInteractionEnabled = false
                cell.textField.layer.borderColor = UIColor.white.cgColor
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 3 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                cell.textField.text = valueString
            })
            +++ Section() {
                $0.tag = "DeliveryAddress"
                if User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = true
                }
            }
            <<< LabelRow() {
                $0.cell.height = { 80.0 }
                $0.title = "Delivery Address".localized
            }.cellUpdate({ (cell, row) in
                var finalString = ""
                if (self.enquiryObject?.line1 != nil && self.enquiryObject?.line1?.isNotBlank ?? false) || (self.orderObject?.line1 != nil && self.orderObject?.line1?.isNotBlank ?? false) {
                    finalString.append(self.enquiryObject?.line1 ?? "")
                }
                if (self.enquiryObject?.line2 != nil && self.enquiryObject?.line2?.isNotBlank ?? false) || (self.orderObject?.line2 != nil && self.orderObject?.line2?.isNotBlank ?? false)  {
                    finalString.append(" \(self.enquiryObject?.line2 ?? "")")
                }
                if (self.enquiryObject?.street != nil && self.enquiryObject?.street?.isNotBlank ?? false) ||
                    (self.orderObject?.street != nil && self.orderObject?.street?.isNotBlank ?? false) {
                    finalString.append(", \(self.enquiryObject?.street ?? "")")
                }
                if (self.enquiryObject?.city != nil && self.enquiryObject?.city?.isNotBlank ?? false) ||
                    (self.orderObject?.city != nil && self.orderObject?.city?.isNotBlank ?? false) {
                    finalString.append(self.enquiryObject?.city ?? "")
                }
                if (self.enquiryObject?.district != nil && self.enquiryObject?.district?.isNotBlank ?? false) ||
                    (self.orderObject?.district != nil && self.orderObject?.district?.isNotBlank ?? false) {
                    finalString.append(" \(self.enquiryObject?.district ?? "")")
                }
                if (self.enquiryObject?.state != nil && self.enquiryObject?.state?.isNotBlank ?? false) ||
                    (self.orderObject?.state != nil && self.orderObject?.state?.isNotBlank ?? false) {
                    finalString.append(", \(self.enquiryObject?.state ?? "")")
                }
                if (self.enquiryObject?.pincode != nil && self.enquiryObject?.pincode?.isNotBlank ?? false) ||
                    (self.orderObject?.pincode != nil && self.orderObject?.pincode?.isNotBlank ?? false) {
                    finalString.append(", \(self.enquiryObject?.pincode ?? "")")
                }
                if (self.enquiryObject?.country != nil && self.enquiryObject?.country?.isNotBlank ?? false) ||
                    (self.orderObject?.country != nil && self.orderObject?.country?.isNotBlank ?? false){
                    finalString.append("\n \(self.enquiryObject?.country ?? "")")
                }
                cell.detailTextLabel?.text = finalString
                cell.detailTextLabel?.numberOfLines = 10
                cell.detailTextLabel?.font = .systemFont(ofSize: 10)
            })
            +++ Section() {
                $0.tag = "OtherDetails"
                $0.hidden = true
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "GST"
                $0.cell.titleLabel.text = "GST Number".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = enquiryObject?.gst ?? orderObject?.gst ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
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
                $0.cell.valueTextField.text = "\(enquiryObject?.pocFirstName ?? orderObject?.pocFirstName ?? "") \(enquiryObject?.pocLastName ?? orderObject?.pocLastName ?? "")"
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "PocMobile"
                $0.cell.titleLabel.text = "Mobile Number".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.height = { 80.0 }
                $0.cell.valueTextField.text = enquiryObject?.pocContact ?? orderObject?.pocContact ?? ""
                $0.cell.valueTextField.textColor = .darkGray
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "PocEmail"
                $0.cell.titleLabel.text = "Email Id".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = enquiryObject?.pocEmail ?? orderObject?.pocEmail ?? ""
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.height = { 80.0 }
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.valueTextField.isUserInteractionEnabled = false
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
    }
    
    @objc func goToChat() {
        
    }
}

class CustomMOQArtisanDetailsController: FormViewController {
    
    var getMOs: GetMOQs?
    var enquiryObject: Enquiry?
    var orderObject: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        form +++
            Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                $0.cell.isUserInteractionEnabled = false
                $0.cell.actionButton.isUserInteractionEnabled = false
                if let name = self.getMOs?.logo, let userID = self.getMOs?.artisanId {
                    let url = URL(string: KeychainManager.standard.imageBaseURL + "/User/\(userID)/CompanyDetails/Logo/\(name)")
                    URLSession.shared.dataTask(with: url!) { data, response, error in
                        // do your stuff here...
                        DispatchQueue.main.async {
                            // do something on the main queue
                            if error == nil {
                                if let finalData = data {
                                    let row = self.form.rowBy(tag: "ProfileView") as? ProfileImageRow
                                    row?.cell.actionButton.setImage(UIImage.init(data: finalData), for: .normal)
                                }
                            }
                        }
                    }.resume()
                }
            }
            <<< LabelRow() {
                $0.title = getMOs?.brand
            }
            <<< LabelRow() {
                $0.title = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? enquiryObject?.productCategoryHistoryId ?? orderObject?.productCategoryId ?? orderObject?.productCategoryHistoryId ?? 0)?.prodCatDescription ?? ""), \(enquiryObject?.clusterName ?? orderObject?.clusterName ?? "")"
        }
        
    }
    
    @objc func goToChat() {
        
    }
}
