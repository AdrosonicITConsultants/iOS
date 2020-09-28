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
    var cgst = Observable<String?>(nil)
    var expectedDateOfDelivery = Observable<String?>(nil)
    var hsn = Observable<String?>(nil)
    var ppu = Observable<String?>(nil)
    var quantity = Observable<String?>(nil)
    var sgst = Observable<String?>(nil)
    var currency = Observable<String?>(nil)
    //    var deleteProductSelected: (() -> Void)?
    var savePI: (() -> ())?
}

class InvoiceController: FormViewController{
    var enquiryObject: Enquiry?
    var viewWillAppear: (() -> ())?
    var showCustomProduct: (() -> ())?
    var showProductDetails: (() -> ())?
    var showHistoryProductDetails: (() -> ())?
    var closeEnquiry: ((_ enquiryId: Int) -> ())?
    
    var saveInvoice: Int = 0
    
    let realm = try? Realm()
    var isClosed = false
    var viewModel = InvoiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        var shouldShowOption = false
        
        if User.loggedIn()?.refRoleId == "1" {
            shouldShowOption = false
        }else {
            if enquiryObject?.enquiryStageId ?? 0 > 3 {
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
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if enquiryObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = enquiryObject?.brandName
                }
                $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "\(enquiryObject?.totalAmount ?? 0)" : "NA"
                $0.cell.statusLbl.text = "\(EnquiryStages.getStageType(searchId: enquiryObject?.enquiryStageId ?? 0)?.stageDescription ?? "-")"
                if enquiryObject?.enquiryStageId ?? 0 < 5 {
                    $0.cell.statusLbl.textColor = .black
                    $0.cell.statusDotView.backgroundColor = .black
                }else if enquiryObject?.enquiryStageId ?? 0 < 9 {
                    $0.cell.statusLbl.textColor = .systemYellow
                    $0.cell.statusDotView.backgroundColor = .systemYellow
                }else {
                    $0.cell.statusLbl.textColor = UIColor().CEGreen()
                    $0.cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let tag = enquiryObject?.productImages?.components(separatedBy: ",").first, let prodId = enquiryObject?.productId {
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
            }
            
            
            <<< EnquiryClosedRow() {
                $0.cell.height = { 110.0 }
                if enquiryObject?.enquiryStageId == 10 {
                    $0.cell.dotView.backgroundColor = UIColor().CEGreen()
                    $0.cell.enquiryLabel.text = "Enquiry Completed".localized
                    $0.cell.enquiryLabel.textColor = UIColor().CEGreen()
                }else {
                    $0.cell.dotView.backgroundColor = .red
                    $0.cell.enquiryLabel.text = "Enquiry Closed".localized
                    $0.cell.enquiryLabel.textColor = .red
                }
                $0.hidden = isClosed == true ? false : true
            }
            <<< TransactionReceiptRow() {
                $0.cell.height = { 110.0 }
                $0.cell.viewProformaInvoiceBtn.setTitle("View\nPro forma\nInvoice", for: .normal)
                if (enquiryObject?.enquiryStageId == 3 || enquiryObject?.enquiryStageId == 8){
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
                if User.loggedIn()?.refRoleId == "1" || isClosed {
                    $0.hidden = true
                }
            }
            <<< LabelRow(){
                $0.title = "Fill in the Details"
            }
            
            
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Quantity"
                $0.cell.height = { 80.0 }
                $0.cell.titleLabel.text =  "Quantity"
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                self.viewModel.quantity.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.quantity.value ?? ""
                self.viewModel.quantity.value = $0.cell.valueTextField.text
                $0.hidden = false
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                //                cell.valueTextField.text = self.viewModel.quantity.value ?? ""
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "date"
                $0.cell.height = { 80.0 }
                $0.cell.titleLabel.text =  "Expected Date of Delivery"
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                
                $0.hidden = false
                
                self.viewModel.expectedDateOfDelivery.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.expectedDateOfDelivery.value ?? ""
                self.viewModel.expectedDateOfDelivery.value = $0.cell.valueTextField.text
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                cell.valueTextField.text = self.viewModel.expectedDateOfDelivery.value ?? ""
                
            })
            
            
            
            //            <<< DateRow(){
            //                $0.title = "Expected Date of Delivery"
            //                $0.cell.height = { 80.0 }
            //                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            ////                self.viewModel.expectedDateOfDelivery.bidirectionalBind(to: $0.cell.value as? String)
            ////                $0.value as! String = self.viewModel.expectedDateOfDelivery.value ?? ""
            //                 self.viewModel.expectedDateOfDelivery.value = $0.value as? String
            //                print( "\(self.viewModel.expectedDateOfDelivery.value)")
            //
            //            }
            
            <<< RoundedTextFieldRow() {
                $0.tag = "Currency"
                $0.cell.titleLabel.text =  "Currency"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                self.viewModel.currency.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.currency.value ?? ""
                self.viewModel.currency.value = $0.cell.valueTextField.text
                
                $0.hidden = false
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                //                cell.valueTextField.text = self.viewModel.currency.value ?? ""
                
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Price Per Unit/m"
                $0.cell.titleLabel.text =  "Price Per Unit/m"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                self.viewModel.ppu.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.ppu.value ?? ""
                self.viewModel.ppu.value = $0.cell.valueTextField.text
                
                $0.hidden = false
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                //                cell.valueTextField.text = self.viewModel.ppu.value ?? ""
                
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "HSNCodeInvoice"
                $0.cell.titleLabel.text =  "HSN Code"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                self.viewModel.hsn.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.hsn.value ?? ""
                self.viewModel.hsn.value = $0.cell.valueTextField.text
                
                $0.hidden = false
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                //                cell.valueTextField.text = self.viewModel.hsn.value ?? ""
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "SGST"
                $0.cell.titleLabel.text =  "SGST"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                self.viewModel.sgst.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.sgst.value ?? ""
                self.viewModel.sgst.value = $0.cell.valueTextField.text
                
                $0.hidden = false
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                //                cell.valueTextField.text = self.viewModel.sgst.value ?? ""
                
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "CGST"
                $0.cell.titleLabel.text =  "CGST"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                self.viewModel.cgst.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.cgst.value ?? ""
                self.viewModel.cgst.value = $0.cell.valueTextField.text
                
                $0.hidden = false
                
            }.cellUpdate({ (cell, row) in
                cell.valueTextField.maxLength = 40
                //                cell.valueTextField.text = self.viewModel.cgst.value ?? ""
            })
            
            //            <<< ProFormaInvoiceRow() {
            //                $0.cell.height = { 150.0 }
            //                $0.cell.delegate = self
            //                $0.tag = "CreatePreviewPI"
            //                $0.cell.tag = 2
            //        }
            
            <<< SwipeInvoiceRow() {
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
                $0.tag = "CreatePreviewPI"
                $0.cell.tag = 2
        }
        
    }
    
    
    @objc func showOptions(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "", message: "Choose", preferredStyle: .actionSheet)
        
        let chat = UIAlertAction.init(title: "Chat", style: .default) { (action) in
            self.goToChat()
        }
        alert.addAction(chat)
        
        let closeEnquiry = UIAlertAction.init(title: "Close Enquiry", style: .default) { (action) in
            self.confirmAction("Warning".localized, "Are you sure you want to close this enquiry?".localized, confirmedCallback: { (action) in
                self.closeEnquiry?(self.enquiryObject?.entityID ?? 0)
            }) { (action) in
                
            }
        }
        alert.addAction(closeEnquiry)
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func goToChat() {
        
    }
    func reloadFormData() {
        enquiryObject = realm?.objects(Enquiry.self).filter("%K == %@","entityID",enquiryObject?.entityID ?? 0).first
        form.allRows .forEach { (row) in
            row.reload()
        }
    }
}
extension InvoiceController: SwipeButtonProtocol {
    func swipeInvoiceBtnSelected(tag: Int){
        switch tag{
        case 2:
            let client = try! SafeClient(wrapping: CraftExchangeClient())
            
            print("\(viewModel.ppu.value),\(viewModel.cgst.value),\(viewModel.currency.value),\(viewModel.expectedDateOfDelivery.value),\(viewModel.hsn.value),\(viewModel.quantity.value)\(viewModel.sgst.value)")
            self.viewModel.savePI?()
            
            let vc1 = EnquiryDetailsService(client: client).piSend(enquiryId: self.enquiryObject!.enquiryId) as! InvoicePreviewController
            vc1.modalPresentationStyle = .fullScreen
            vc1.enquiryObject = self.enquiryObject
            
            print("PI WORKING")
            
            self.navigationController?.pushViewController(vc1, animated: true)
            
        default:
            print("NOt Working SavePI")
        }
    }
    
    
    
}


