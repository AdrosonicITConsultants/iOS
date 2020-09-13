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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let realm = try? Realm()
        let accountDetails = realm?.objects(PaymentAccDetails.self).filter("%K == %@","userId",enquiryObject?.userId ?? 0)
        form +++
        Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                $0.cell.isUserInteractionEnabled = false
                $0.cell.actionButton.isUserInteractionEnabled = false
                if let name = self.enquiryObject?.logo, let userID = self.enquiryObject?.userId {
                    let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/User/\(userID)/CompanyDetails/Logo/\(name)")
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
                $0.title = enquiryObject?.brandName
            }
            <<< LabelRow() {
                $0.title = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? enquiryObject?.productCategoryHistoryId ?? 0)?.prodCatDescription ?? ""), \(enquiryObject?.clusterName ?? "")"
            }
            <<< LabelRow() {
                $0.title = "\(enquiryObject?.firstName ?? "") \(enquiryObject?.lastName ?? "")"
            }
            <<< LabelRow() {
                $0.title = enquiryObject?.eqDescription
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
                $0.value = lbl
            }
            <<< SegmentedRow() { row in
                row.options = ["Bank Details", "Digital Payment Details"]
            }.onChange({ (row) in
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
            })
            +++ Section() {section in
                section.tag = "BankSection"
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
    }
}
