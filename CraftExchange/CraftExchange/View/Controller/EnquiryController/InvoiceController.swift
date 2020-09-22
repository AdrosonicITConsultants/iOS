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
   var quantity = Observable<String?>(nil)
     var Currency = Observable<String?>(nil)
     var Price = Observable<String?>(nil)
     var HSNCodeInvoice = Observable<String?>(nil)
     var SGST = Observable<String?>(nil)
     var CGST = Observable<String?>(nil)
}

class InvoiceController: FormViewController{
    var enquiryObject: Enquiry?
    var viewWillAppear: (() -> ())?
    var showCustomProduct: (() -> ())?
    var showProductDetails: (() -> ())?
    var showHistoryProductDetails: (() -> ())?
    var closeEnquiry: ((_ enquiryId: Int) -> ())?
    let realm = try? Realm()
    var isClosed = false
   lazy var viewModel = InvoiceViewModel()
    
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
                            <<< MOQSectionTitleRow() {
                                                        $0.cell.height = { 54.0 }
                                                        $0.cell.titleLbl.text = "Check MOQ"
                                                        $0.cell.noOfUnitLbl.text = "70 pcs"
                                                        $0.cell.costLbl.text = "Rs 1000"
                                                        $0.cell.etaLbl.text = "100 days"
                                                        $0.cell.contentView.backgroundColor = UIColor().EQGreenBg()
                                                        $0.cell.titleLbl.textColor = UIColor().EQGreenText()
                                                        $0.cell.noOfUnitLbl.textColor = UIColor().EQGreenText()
                                                        $0.cell.costLbl.textColor = UIColor().EQGreenText()
                                                        $0.cell.etaLbl.textColor = UIColor().EQGreenText()
                                                        
                                                    }.onCellSelection({ (cell, row) in
                                                        let row1 = self.form.rowBy(tag: "MOQ1")
                                                        let row2 = self.form.rowBy(tag: "MOQ2")
                                                        let row3 = self.form.rowBy(tag: "MOQ3")
                                                        if row1?.isHidden == true {
                                                            row1?.hidden = false
                                                            row2?.hidden = false
                                                            row3?.hidden = false
                                                        }else {
                                                            row1?.hidden = true
                                                            row2?.hidden = true
                                                            row3?.hidden = true
                                                        }
                                                        row1?.evaluateHidden()
                                                        row2?.evaluateHidden()
                                                        row3?.evaluateHidden()
                                                        self.form.allSections.first?.reload(with: .none)
                                                    })
                                                    <<< MOQValueRow() {
                                                        $0.cell.height = { 60.0 }
                                                        $0.tag = "MOQ1"
                                                        $0.cell.unitLbl.text = "MOQ"
                                                        $0.cell.valueLbl.text = "70 pcs"
                                                        $0.hidden = true
                                                    }
                                                    <<< MOQValueRow() {
                                                        $0.cell.height = { 60.0 }
                                                        $0.tag = "MOQ2"
                                                        $0.cell.unitLbl.text = "Price/unit(or m)"
                                                        $0.cell.valueLbl.text = "Rs 1000"
                                                        $0.hidden = true
                                                    }
                                                    <<< MOQValueRow() {
                                                        $0.cell.height = { 60.0 }
                                                        $0.tag = "MOQ3"
                                                        $0.cell.unitLbl.text = "Price/unit(or m)"
                                                        $0.cell.valueLbl.text = "Rs 1000"
                                                        $0.hidden = true
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
                
//                        <<< InvoiceTextFieldRow() {
//                            $0.tag = "TitleInvoice"
//                            $0.cell.height = { 80.0 }
//                            $0.cell.backgroundColor = .white
//                            $0.cell.InvoiceLabel.text = "Quantity"
//                            $0.cell.InvoiceLabel.textColor = .black
//                            $0.cell.InvoiceLabel.font = .systemFont(ofSize: 14, weight: .regular)
//                            self.viewModel.quantity.bidirectionalBind(to: $0.cell.InvoiceTF.reactive.text)
//                            $0.cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                            self.viewModel.quantity.value = $0.cell.InvoiceTF.text
//                             $0.cell.InvoiceTF.placeholder = " _____________ "
////
//
//                             $0.hidden = false
//                                    }.cellUpdate({ (cell, row) in
////                                        $0.cell.InvoiceTF.maxLength = 40
//                                          cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                        cell.isUserInteractionEnabled = true
//
//                                        cell.InvoiceTF.isUserInteractionEnabled = true
//                                                           })
//                            <<< InvoiceTextFieldRow() {
//                                                        $0.tag = "DateInvoice"
//                                                        $0.cell.height = { 80.0 }
//                                                        $0.cell.backgroundColor = .white
//                                                        $0.cell.InvoiceLabel.text = "Date of Delivery"
//                                                        $0.cell.InvoiceLabel.textColor = .black
//                                                        $0.cell.InvoiceLabel.font = .systemFont(ofSize: 14, weight: .regular)
//                                                        $0.cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                                        $0.cell.InvoiceTF.layer.borderColor = UIColor.white.cgColor
//
//                                                         $0.hidden = false
//                                                                }.cellUpdate({ (cell, row) in
//                            //                                        $0.cell.InvoiceTF.maxLength = 40
//                                                                  cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                                                                       })
//
//             <<< InvoiceTextFieldRow() {
//                                        $0.tag = "CurrencyInvoice"
//                                        $0.cell.height = { 80.0 }
//                                        $0.cell.backgroundColor = .white
//                                        $0.cell.InvoiceLabel.text = "Currency"
//                                        $0.cell.InvoiceLabel.textColor = .black
//                                        $0.cell.InvoiceLabel.font = .systemFont(ofSize: 14, weight: .regular)
//                                       $0.cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                       self.viewModel.quantity.value = $0.cell.InvoiceTF.text
//                                        $0.cell.InvoiceTF.layer.borderColor = UIColor.white.cgColor
//
//                                         $0.hidden = false
//                                                }.cellUpdate({ (cell, row) in
//            //                                        $0.cell.InvoiceTF.maxLength = 40
//                                                  cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                                                       })
//             <<< InvoiceTextFieldRow() {
//                                        $0.tag = "HSNCodeInvoice"
//                                        $0.cell.height = { 80.0 }
//                                        $0.cell.backgroundColor = .white
//                                        $0.cell.InvoiceLabel.text = "HSNCode"
//                                        $0.cell.InvoiceLabel.textColor = .black
//                                        $0.cell.InvoiceLabel.font = .systemFont(ofSize: 14, weight: .regular)
//                                        $0.cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                        $0.cell.InvoiceTF.layer.borderColor = UIColor.white.cgColor
//
//                                         $0.hidden = false
//                                                }.cellUpdate({ (cell, row) in
//                                                 cell.InvoiceTF.text = self.viewModel.quantity.value ?? ""
//                                                                       })
            
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
                                                        cell.valueTextField.text = self.viewModel.quantity.value ?? ""
                            //                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                                                       })
                            
                            <<< RoundedActionSheetRow() {
                                $0.tag = "DateInvoice"
                                $0.cell.titleLabel.text = "Expected Date of Delivery"
                                $0.cell.compulsoryIcon.isHidden = true
                               
                                $0.cell.selectedVal = "kikra"
                                $0.value = "kirannnn"
                                $0.cell.delegate = self
                                $0.cell.height = { 80.0 }
                                $0.hidden = false
                                
                            }.cellUpdate({ (cell, row) in
                                 cell.selectedVal = "kikra"
                               
                                                       })
                            ////
                           <<< RoundedTextFieldRow() {
                               $0.tag = "date"
                               $0.cell.height = { 80.0 }
                            $0.cell.titleLabel.text =  "Expected Date of Delivery"
                               $0.cell.compulsoryIcon.isHidden = true
                               $0.cell.backgroundColor = .white
                               $0.cell.valueTextField.textColor = .black
//                               self.viewModel.DateInvoice.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
//                                                          $0.cell.valueTextField.text = self.viewModel.DateInvoice.value ?? ""
//                                                          self.viewModel.DateInvoice.value = $0.cell.valueTextField.text
                                $0.hidden = false

                           }.cellUpdate({ (cell, row) in
                               cell.valueTextField.maxLength = 40
//                            cell.valueTextField.text = self.viewModel.DateInvoice.value ?? ""
//                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                           })
////
                            <<< RoundedTextFieldRow() {
                                                           $0.tag = "Currency"
                                                            $0.cell.titleLabel.text =  "Currency"
                                                           $0.cell.height = { 80.0 }
                                                           $0.cell.compulsoryIcon.isHidden = true
                                                           $0.cell.backgroundColor = .white
                                                           $0.cell.valueTextField.textColor = .black
                                                           self.viewModel.Currency.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                                                                                      $0.cell.valueTextField.text = self.viewModel.Currency.value ?? ""
                                                                                      self.viewModel.Currency.value = $0.cell.valueTextField.text
                                                           
                                                            $0.hidden = false

                                                       }.cellUpdate({ (cell, row) in
                                                           cell.valueTextField.maxLength = 40
                                                        cell.valueTextField.text = self.viewModel.Currency.value ?? ""
                            //                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                                                       })
                            <<< RoundedTextFieldRow() {
                                                           $0.tag = "Price Per Unit/m"
                                                             $0.cell.titleLabel.text =  "Price Per Unit/m"
                                                           $0.cell.height = { 80.0 }
                                                           $0.cell.compulsoryIcon.isHidden = true
                                                           $0.cell.backgroundColor = .white
                                                           $0.cell.valueTextField.textColor = .black
                                                           self.viewModel.Price.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                                                                                      $0.cell.valueTextField.text = self.viewModel.Price.value ?? ""
                                                                                      self.viewModel.Price.value = $0.cell.valueTextField.text
                                                           
                                                            $0.hidden = false

                                                       }.cellUpdate({ (cell, row) in
                                                           cell.valueTextField.maxLength = 40
                                                        cell.valueTextField.text = self.viewModel.Price.value ?? ""
                            //                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                                                       })
                            <<< RoundedTextFieldRow() {
                                                                           $0.tag = "HSNCodeInvoice"
                                                                             $0.cell.titleLabel.text =  "HSN Code"
                                                                           $0.cell.height = { 80.0 }
                                                                           $0.cell.compulsoryIcon.isHidden = true
                                                                           $0.cell.backgroundColor = .white
                                                                           $0.cell.valueTextField.textColor = .black
                                                                           self.viewModel.HSNCodeInvoice.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                                                                                                      $0.cell.valueTextField.text = self.viewModel.HSNCodeInvoice.value ?? ""
                                                                                                      self.viewModel.HSNCodeInvoice.value = $0.cell.valueTextField.text
                                                                           
                                                                            $0.hidden = false

                                                                       }.cellUpdate({ (cell, row) in
                                                                           cell.valueTextField.maxLength = 40
                                                                        cell.valueTextField.text = self.viewModel.HSNCodeInvoice.value ?? ""
                                            //                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                                                                       })
                            <<< RoundedTextFieldRow() {
                                                                           $0.tag = "SGST"
                                                                             $0.cell.titleLabel.text =  "SGST"
                                                                           $0.cell.height = { 80.0 }
                                                                           $0.cell.compulsoryIcon.isHidden = true
                                                                           $0.cell.backgroundColor = .white
                                                                           $0.cell.valueTextField.textColor = .black
                                                                           self.viewModel.SGST.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                                                                                                      $0.cell.valueTextField.text = self.viewModel.SGST.value ?? ""
                                                                                                      self.viewModel.SGST.value = $0.cell.valueTextField.text
                                                                           
                                                                            $0.hidden = false

                                                                       }.cellUpdate({ (cell, row) in
                                                                           cell.valueTextField.maxLength = 40
                                                                        cell.valueTextField.text = self.viewModel.SGST.value ?? ""
                                            //                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                                                                       })
                            <<< RoundedTextFieldRow() {
                                                                           $0.tag = "CGST"
                                                                             $0.cell.titleLabel.text =  "CGST"
                                                                           $0.cell.height = { 80.0 }
                                                                           $0.cell.compulsoryIcon.isHidden = true
                                                                           $0.cell.backgroundColor = .white
                                                                           $0.cell.valueTextField.textColor = .black
                                                                           self.viewModel.CGST.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                                                                                                      $0.cell.valueTextField.text = self.viewModel.CGST.value ?? ""
                                                                                                      self.viewModel.CGST.value = $0.cell.valueTextField.text
                                                                           
                                                                            $0.hidden = false

                                                                       }.cellUpdate({ (cell, row) in
                                                                           cell.valueTextField.maxLength = 40
                                                                        cell.valueTextField.text = self.viewModel.CGST.value ?? ""
                                            //                                                       cell.valueTextField.text = self.viewModel.prodName.value ?? ""
                                                                       })
                           
                           <<< BuyerEnquirySectionViewRow() {
                               $0.cell.height = { 44.0 }
                               if User.loggedIn()?.refRoleId == "2" {
                                   $0.cell.titleLbl.text = "Check artisan's details"
                               }else {
                                   $0.cell.titleLbl.text = "Check buyer's details"
                               }
                               $0.cell.valueLbl.text = "Brand: \(enquiryObject?.brandName ?? "NA")"
                               $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                               $0.cell.titleLbl.textColor = UIColor().EQBlueText()
                               $0.cell.valueLbl.textColor = UIColor().EQBlueText()
                           }.onCellSelection({ (cell, row) in
                               let vc = EnquiryArtisanDetailsController.init(style: .plain)
                               vc.enquiryObject = self.enquiryObject
                               self.navigationController?.pushViewController(vc, animated: true)
                           })
                        
                           <<< BuyerEnquirySectionViewRow() {
                               $0.cell.height = { 44.0 }
                               $0.cell.titleLbl.text = "Check PI"
                               if let date = enquiryObject?.lastUpdated {
                                   $0.cell.valueLbl.text = "Received: \(Date().ttceFormatter(isoDate: date))"
                               }
                               $0.cell.contentView.backgroundColor = UIColor().EQPurpleBg()
                               $0.cell.titleLbl.textColor = UIColor().EQPurpleText()
                               $0.cell.valueLbl.textColor = UIColor().EQPurpleText()
                               if (enquiryObject?.isPiSend == 1){
                                   $0.hidden = false
                               }else {
                                   $0.hidden = true
                               }
                           }
                           <<< BuyerEnquirySectionViewRow() {
                               $0.cell.height = { 44.0 }
                               $0.cell.titleLbl.text = "Check Product Details"
                               $0.cell.valueLbl.text = "\(enquiryObject?.productName ?? "Design By")"
                               $0.cell.contentView.backgroundColor = UIColor().EQBrownBg()
                               $0.cell.titleLbl.textColor = UIColor().EQBrownText()
                               $0.cell.valueLbl.textColor = UIColor().EQBrownText()
                           }.onCellSelection({ (cell, row) in
                               if self.enquiryObject?.productType == "Custom Product" {
                                   self.showCustomProduct?()
                               }else if self.enquiryObject?.historyProductId != 0 {
                                   self.showHistoryProductDetails?()
                               }
                               else {
                                   self.showProductDetails?()
                               }
                           })
                           <<< ProFormaInvoiceRow() {
                               $0.cell.height = { 150.0 }
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
extension InvoiceController: InvoiceButtonProtocol {
    func createSendInvoiceBtnSelected(tag: Int) {
        switch tag{
        case 2:
            let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "InvoicePreviewController") 
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            print("PreviewPI WORKING")
        default:
            print("NOt Working PreviewPI")
        }
    }
    
    
    
}

     
