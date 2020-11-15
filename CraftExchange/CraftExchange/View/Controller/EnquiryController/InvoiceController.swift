//
//  InvoiceController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 18/09/20.
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
import ViewRow
import WebKit
class InvoiceViewModel {
    var expectedDateOfDelivery = Observable<String?>(nil)
    var hsn = Observable<String?>(nil)
    var pricePerUnitPI = Observable<String?>(nil)
    var quantity = Observable<String?>(nil)
    var currency = Observable<CurrencySigns?>(nil)
    var currenyNew = Observable<String?>(nil)
    var previousTotalAmount = Observable<String?>(nil)
    var advancePaidAmount = Observable<String?>(nil)
    var sgst = Observable<String?>(nil)
    var cgst = Observable<String?>(nil)
    var deliveryCharges = Observable<String?>(nil)
    var finalamount = Observable<String?>(nil)
    var amountToBePaid = Observable<String?>(nil)
    var checkBox = Observable<Int?>(nil)
    var isOld = Observable<Int?>(nil)
    var savePI: (() -> ())?
    var sendPI: (() -> ())?
    var downloadPI: (() -> ())?
    var sendFI: ((_ isSave: Int) -> ())?
}

class InvoiceController: FormViewController{
    var enquiryObject: Enquiry?
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    var showCustomProduct: (() -> ())?
    var showProductDetails: (() -> ())?
    var showHistoryProductDetails: (() -> ())?
    var closeEnquiry: ((_ enquiryId: Int) -> ())?
    var PI: GetPI?
    var advancePaymnet: PaymentStatus?
    var previewPI: ((_ isOld: Int) -> ())?
    var saveInvoice: Int = 0
    let realm = try? Realm()
    var isClosed = false
    var viewModel = InvoiceViewModel()
    var allCurrencySigns: Results<CurrencySigns>?
    var isRevisedPI: Bool = false
    var isFI : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.checkBox.value = 0
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        allCurrencySigns = realm!.objects(CurrencySigns.self).sorted(byKeyPath: "entityID")
        var shouldShowOption = false
        
        if User.loggedIn()?.refRoleId == "1" {
            shouldShowOption = false
        }else {
            if enquiryObject?.enquiryStageId ?? orderObject?.enquiryStageId ?? 0 > 3 {
                shouldShowOption = false
            }else {
                shouldShowOption = false
            }
        }
        if shouldShowOption && isClosed == true {
            let rightButtonItem = UIBarButtonItem.init(title: "Options".localized, style: .plain, target: self, action: #selector(showOptions(_:)))
            rightButtonItem.tintColor = .darkGray
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }else if isClosed == false {
            let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(goToChat))
            rightButtonItem.image = UIImage.init(named: "ios magenta chat")
            rightButtonItem.tintColor = UIColor().CEMagenda()
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
        form
            +++ Section()
            
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if enquiryObject?.productType ?? orderObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = enquiryObject?.brandName ?? orderObject?.brandName
                }
                $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "\(enquiryObject?.totalAmount ?? 0)" : "NA"
                if orderObject != nil {
                    $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "\(orderObject?.totalAmount ?? 0)" : "NA"
                }
                $0.cell.statusLbl.text = "\(EnquiryStages.getStageType(searchId: enquiryObject?.enquiryStageId ?? orderObject?.enquiryStageId ?? 0)?.stageDescription ?? "-")"
                if enquiryObject?.enquiryStageId ?? orderObject?.enquiryStageId ?? 0 < 5 {
                    $0.cell.statusLbl.textColor = .black
                    $0.cell.statusDotView.backgroundColor = .black
                }else if enquiryObject?.enquiryStageId ?? orderObject?.enquiryStageId ?? 0 < 9 {
                    $0.cell.statusLbl.textColor = .systemYellow
                    $0.cell.statusDotView.backgroundColor = .systemYellow
                }else {
                    $0.cell.statusLbl.textColor = UIColor().CEGreen()
                    $0.cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let date = orderObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date)))"
                }
                if let tag = enquiryObject?.productImages?.components(separatedBy: ",").first ?? orderObject?.productImages?.components(separatedBy: ",").first,
                    let prodId = enquiryObject?.productId ?? orderObject?.productId {
                    if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        $0.cell.productImage.image = downloadedImage
                    }else {
                        do {
                            let client = try SafeClient(wrapping: CraftExchangeImageClient())
                            let service = ProductImageService.init(client: client)
                            service.fetch(withId: prodId, withName: tag).observeNext { (attachment) in
                                DispatchQueue.main.async {
                                    _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    let row = self.form.rowBy(tag: "EnquiryDetailsRow") as! EnquiryDetailsRow
                                    row.cell.productImage.image = UIImage.init(data: attachment)
                                    row.reload()
                                }
                            }.dispose(in: bag)
                        }catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
            <<< LabelRow(){
                $0.title = "Proforma Invoice"
                if  self.isFI {
                    $0.title = "Tax Invoice".localized
                }
//                if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.title = "Tax Invoice".localized
//                }
            }
            
            <<< LabelRow(){
                $0.title = "Fill in the Details".localized
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .darkGray
                 cell.selectionStyle = .none
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Quantity"
                $0.cell.height = { 80.0 }
                $0.cell.titleLabel.text =  "Quantity".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "12"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.quantity.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.quantity.value ?? ""
                if PI?.quantity != nil {
                    $0.cell.valueTextField.text = "\(PI?.quantity ?? 0)"
                }
                self.viewModel.quantity.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 6
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            <<< DateRow(){
                $0.title = "Expected Date of Delivery".localized
                $0.cell.height = { 60.0 }
                $0.minimumDate = Date()
                if  self.isFI  {
                    $0.hidden = true
                }
//                if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = true
//                }
                $0.value = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.string(from: $0.value!)
                self.viewModel.expectedDateOfDelivery.value = date
            }.onChange({ (row) in
                if let value = row.value {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.string(from: value)
                    self.viewModel.expectedDateOfDelivery.value = date
                }
            }).cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                 cell.selectionStyle = .none
            })
            
            <<< RoundedActionSheetRow() {
                $0.tag = "Currency"
                $0.cell.titleLabel.text = "Currency".localized
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.options = ["₹"]
//                $0.cell.options = allCurrencySigns?.compactMap {
//                    $0.sign
//                }
            //    self.viewModel.currency.value = CurrencySigns.getCurrencyType(CurrencyId: 1)
                self.viewModel.currenyNew.value = "₹"
//                if let selectedCurrency = self.viewModel.currency.value {
//                    $0.cell.selectedVal = selectedCurrency.sign
//                    $0.value = selectedCurrency.sign
//                }
                $0.value = "₹"
                $0.cell.actionButton.setTitle($0.value, for: .normal)
                $0.cell.delegate = self
                $0.cell.height = { 80.0 }
                
            }.onChange({ (row) in
                print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
//                let selectedCurrencyObj = self.allCurrencySigns?.filter({ (obj) -> Bool in
//                    obj.sign == row.value
//                }).first
               // self.viewModel.currency.value = selectedCurrencyObj
                 self.viewModel.currenyNew.value = "₹"
            }).cellUpdate({ (cell, row) in
                
//                if let selectedCurrency = self.viewModel.currency.value {
//                    cell.selectedVal = selectedCurrency.sign
//                    cell.row.value = selectedCurrency.sign
//                }
                if let selectedCurrency = self.viewModel.currenyNew.value {
                    cell.selectedVal = selectedCurrency
                    cell.row.value = selectedCurrency
                }
                cell.actionButton.setTitle(cell.row.value, for: .normal)
                 cell.selectionStyle = .none
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Price Per Unit/m"
                $0.cell.titleLabel.text =  "Price Per Unit/m".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.height = { 80.0 }
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.pricePerUnitPI.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.pricePerUnitPI.value ?? ""
                if PI?.ppu != nil {
                    $0.cell.valueTextField.text = "\(PI?.ppu ?? 0)"
                }
                self.viewModel.pricePerUnitPI.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 6
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Previous total amount"
                $0.cell.titleLabel.text =  "Previous Total amount(as per PI)".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.height = { 80.0 }
                if  self.orderObject?.productStatusId != 2 && self.isFI  {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = true
//
//                }
                else{
                    $0.hidden = true
                }
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.previousTotalAmount.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.previousTotalAmount.value ?? ""
                if PI?.totalAmount != nil {
                    $0.cell.valueTextField.text = "\(PI?.totalAmount ?? 0)"
                }
                self.viewModel.previousTotalAmount.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                // cell.valueTextField.maxLength = 6
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Advance payment received"
                $0.cell.titleLabel.text =  "Advance payment received (Previously as per PI)".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.height = { 80.0 }
                if  self.orderObject?.productStatusId != 2 && self.isFI  {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = true
//
//                }
                else {
                    $0.hidden = true
                }
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.advancePaidAmount.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.advancePaidAmount.value ?? ""
                //  if enquiryObject?.productStatusId != 2 {
                if advancePaymnet?.paidAmount != nil {
                    $0.cell.valueTextField.text = "\(advancePaymnet?.paidAmount ?? 0)"
                }else{
                    $0.cell.valueTextField.text = "0"
                }
                
                // }
                self.viewModel.advancePaidAmount.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                // cell.valueTextField.maxLength = 6
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Sgst"
                $0.cell.height = { 80.0 }
                if  self.isFI {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = false
//                }
                else {
                    $0.hidden = true
                }
                $0.cell.titleLabel.text =  "SGST %".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "12"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.sgst.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text =  "0"
                self.viewModel.sgst.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                //   cell.valueTextField.maxLength = 2
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Cgst"
                $0.cell.height = { 80.0 }
                if  self.isFI {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = false
//                }
                else {
                    $0.hidden = true
                }
                $0.cell.titleLabel.text =  "CGST %"
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "12"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.cgst.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = "0"
                self.viewModel.cgst.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                // cell.valueTextField.maxLength = 2
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Final amount"
                $0.cell.titleLabel.text =  "Final Amount".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.height = { 80.0 }
                if  self.isFI {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = false
//                }
                else {
                    $0.hidden = true
                }
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.finalamount.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.finalamount.value ?? ""
                if PI?.totalAmount != nil {
                    $0.cell.valueTextField.text = "\(PI?.totalAmount ?? 0)"
                }
                self.viewModel.finalamount.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                // cell.valueTextField.maxLength = 6
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Amount to be paid"
                $0.cell.titleLabel.text =  "Amount to be paid (Final Amount - Advanced Payment)".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.height = { 80.0 }
                if  self.orderObject?.productStatusId != 2 && self.isFI  {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = true
//
//                }
                else {
                    $0.hidden = true
                }
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.amountToBePaid.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.amountToBePaid.value ?? ""
                if enquiryObject?.productStatusId != 2 {
                    if PI?.totalAmount != nil && advancePaymnet?.paidAmount != nil {
                        $0.cell.valueTextField.text = "\((PI?.totalAmount ?? 0) - (advancePaymnet?.paidAmount ?? 0))"
                    }else if PI?.totalAmount != nil && advancePaymnet?.paidAmount == nil{
                        $0.cell.valueTextField.text = "\(PI?.totalAmount ?? 0)"
                        
                    }
                    
                }
                self.viewModel.amountToBePaid.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                // cell.valueTextField.maxLength = 6
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Delivery Charges"
                $0.cell.height = { 80.0 }
                if  self.isFI  {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = false
//                }
                else {
                    $0.hidden = true
                }
                $0.cell.titleLabel.text =  "Delivery charges(Freight Charges)".localized
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "12"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.deliveryCharges.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = "0"
                self.viewModel.deliveryCharges.value = $0.cell.valueTextField.text
            }.cellUpdate({ (cell, row) in
                // cell.valueTextField.maxLength = 2
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            
            <<< RoundedTextFieldRow() {
                $0.tag = "HSNCodeInvoice"
                $0.cell.titleLabel.text =  "HSN Code"
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.height = { 80.0 }
                if  self.isFI  {
                    $0.hidden = true
                }
//                    if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = true
//                }
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "12345678"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.hsn.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.hsn.value ?? ""
                self.viewModel.hsn.value = $0.cell.valueTextField.text
                if PI?.quantity != nil {
                    $0.cell.valueTextField.text = "\(PI?.hsn ?? 12345678)"
                }
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 8
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                 cell.selectionStyle = .none
            })
            
            <<< ToggleOptionRow() {
                $0.cell.height = { 60.0 }
                $0.cell.titleLbl.text = "Agree to terms and Conditions".localized
                if  self.isFI  {
                    $0.hidden = false
                }
//                else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//                    $0.hidden = false
//                }
                else {
                    $0.hidden = true
                }
                if self.viewModel.checkBox.value == 1 {
                    $0.cell.titleLbl.textColor = UIColor().menuSelectorBlue()
                    $0.cell.toggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                }else {
                    $0.cell.titleLbl.textColor = .lightGray
                    $0.cell.toggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                }
                $0.cell.washCare = false
                $0.cell.toggleDelegate = self
               // $0.cell.toggleButton.tag = 100
            }.onCellSelection({ (cell, row) in
                
                self.didTapFAQButton(tag: 3)
              //  cell.toggleButton.sendActions(for: .touchUpInside)
               // cell.contentView.backgroundColor = .white
            }).cellUpdate({ (cell, row) in
                 cell.selectionStyle = .none
            })
            
            <<< LabelRow(){
                $0.cell.height = {30.0}
                $0.title = ""
            }
            
            <<< SingleButtonRow() {
                $0.tag = "CreatePreviewPI"
                $0.cell.singleButton.backgroundColor = .blue
                $0.cell.singleButton.setTitleColor(.white, for: .normal)
                if isRevisedPI {
                    $0.cell.singleButton.setTitle("Send Revised PI".localized, for: .normal)
                }else {
                    $0.cell.singleButton.setTitle("Save and Preview Invoice".localized, for: .normal)
                }
                $0.cell.height = { 50.0 }
                $0.cell.delegate = self as SingleButtonActionProtocol
                $0.cell.tag = 101
            }.cellUpdate({ (cell, row) in
                 cell.selectionStyle = .none
            })
            
        <<< LabelRow(){
            $0.cell.height = {30.0}
            $0.title = ""
        }.cellUpdate({ (cell, row) in
            cell.selectionStyle = .none
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "PIRevised"), object: nil, queue: .main) { (notif) in
            self.hideLoading()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc func showOptions(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "", message: "Choose".localized, preferredStyle: .actionSheet)
        
        let chat = UIAlertAction.init(title: "Chat".localized, style: .default) { (action) in
            self.goToChat()
        }
        alert.addAction(chat)
        
        let closeEnquiry = UIAlertAction.init(title: "Close Enquiry", style: .default) { (action) in
            self.confirmAction("Warning".localized, "Are you sure you want to close this enquiry?".localized, confirmedCallback: { (action) in
                self.closeEnquiry?(self.enquiryObject?.entityID ?? self.orderObject?.entityID ?? 0)
            }) { (action) in
                
            }
        }
        alert.addAction(closeEnquiry)
        
        let cancel = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func goToChat() {
        
    }
    func reloadFormData() {
        if enquiryObject != nil {
            enquiryObject = realm?.objects(Enquiry.self).filter("%K == %@","entityID",enquiryObject?.entityID ?? 0).first
        }else if orderObject != nil {
            orderObject = realm?.objects(Order.self).filter("%K == %@","entityID",orderObject?.entityID ?? 0).first
        }
        form.allRows .forEach { (row) in
            row.reload()
        }
    }
}

extension InvoiceController:  SingleButtonActionProtocol, PreviewPIViewProtocol, ToggleButtonProtocol {
    
    func toggleButtonSelected(tag: Int, forWashCare: Bool) {
        if self.viewModel.checkBox.value != 1{
            self.viewModel.checkBox.value = 1
        }else{
             self.viewModel.checkBox.value = 0
        }
    }
    //preview PI/FI
    func backButtonSelected() {
        self.view.hidePreviewPIView()
    }
    
//    func downloadButtonSelected() {
//        if enquiryObject?.enquiryId == 2 {
//            self.viewModel.downloadPI?()
//        }
//        if self.isFI  {
//            print("download tax invoice")
//        }
////        else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
////           print("download tax invoice")
////        }
//    }
    
    func sendButtonClicked() {
        self.showLoading()
        
        if enquiryObject?.enquiryId == 2 {
            self.viewModel.sendPI?()
        }
        if self.isFI  {
            self.viewModel.sendFI?(2)
        }
//        else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//           self.viewModel.sendFI?(2)
//        }
    }
    // save PI Button
    func singleButtonSelected(tag: Int) {
        switch tag{
        case 101:
            self.showLoading()
            if self.isFI  {
                //self.viewModel.isOld.value = 0
                
               // self.hideLoading()
                
                self.viewModel.sendFI?(1)
            }
//            else if self.orderObject?.productStatusId == 2 && self.orderObject?.enquiryStageId == 3 {
//               self.viewModel.sendFI?(1)
//            }
            else{
                self.viewModel.isOld.value = 0
                self.viewModel.savePI?()
                
            }
            
        default:
            print("do nothing")
        }
    }
}


