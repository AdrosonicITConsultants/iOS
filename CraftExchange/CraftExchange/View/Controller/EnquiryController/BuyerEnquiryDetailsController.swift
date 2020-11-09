//
//  BuyerEnquiryDetailsController.swift
//  CraftExchange
//
//  Created by Preety Singh on 07/09/20.
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
import ViewRow
import WebKit

class BuyerEnquiryDetailsController: FormViewController {
    var enquiryObject: Enquiry?
    var getMOQ: GetMOQ?
    var getMOQs: GetMOQ?
    var listMOQs: [GetMOQs]?
    var viewWillAppear: (() -> ())?
    var checkMOQ: (() -> ())?
    var checkMOQs: (() -> ())?
    var getPI: (() -> ())?
    var PI: GetPI?
    lazy var viewModel = CreateMOQModel()
    var allDeliveryTimes: Results<EnquiryMOQDeliveryTimes>?
    var innerStages: Results<EnquiryInnerStages>?
    var sendMOQ: (() -> ())?
    var acceptMOQ: (() -> ())?
    var sentMOQ: Int = 0
    var viewPI: ((_ isOld: Int) -> ())?
    var downloadPI: (() -> ())?
    var isMOQNeedToAccept: Int = 0
    var showCustomProduct: (() -> ())?
    var showProductDetails: (() -> ())?
    var showHistoryProductDetails: (() -> ())?
    var closeEnquiry: ((_ enquiryId: Int) -> ())?
    let realm = try? Realm()
    var isClosed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        allDeliveryTimes = realm!.objects(EnquiryMOQDeliveryTimes.self).sorted(byKeyPath: "entityID")
        innerStages = realm!.objects(EnquiryInnerStages.self).sorted(byKeyPath: "entityID")
        checkMOQ?()
        checkMOQs?()
        getPI?()
        var shouldShowOption = false
        
        if User.loggedIn()?.refRoleId == "1" {
            shouldShowOption = false
        }else {
            if enquiryObject?.enquiryStageId ?? 0 > 3 {
                shouldShowOption = false
            }else {
                shouldShowOption = true
            }
        }
        if shouldShowOption && isClosed == false {
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
            }.cellUpdate({ (cell, row) in
                cell.statusLbl.text = "\(EnquiryStages.getStageType(searchId: self.enquiryObject?.enquiryStageId ?? 0)?.stageDescription ?? "-")"
                if self.enquiryObject?.enquiryStageId ?? 0 < 5 {
                    cell.statusLbl.textColor = .black
                    cell.statusDotView.backgroundColor = .black
                }else if self.enquiryObject?.enquiryStageId ?? 0 < 9 {
                    cell.statusLbl.textColor = .systemYellow
                    cell.statusDotView.backgroundColor = .systemYellow
                }else {
                    cell.statusLbl.textColor = UIColor().CEGreen()
                    cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                if let date = self.enquiryObject?.lastUpdated {
                    cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
            })
            
            <<< LabelRow(){
                $0.title = "Enquiry Details".localized
            }
            
            <<< StatusRow() {
                $0.cell.height = { 110.0 }
            }.cellUpdate({ (cell, row) in
                
                cell.previousStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (self.enquiryObject?.enquiryStageId ?? 0) - 1)?.stageDescription ?? "NA")"
                if self.enquiryObject!.enquiryStageId == 3 && self.enquiryObject?.productStatusId == 2 {
                    cell.previousStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (self.enquiryObject?.enquiryStageId ?? 0) - 4)?.stageDescription ?? "NA")"
                }
                if self.enquiryObject?.enquiryStageId == 5 && self.enquiryObject!.innerEnquiryStageId >= 2{
                    cell.previousStatusLbl.text = "\(EnquiryInnerStages.getStageType(searchId: (self.enquiryObject?.innerEnquiryStageId ?? 0) - 1)?.stageDescription ?? "NA")"
                }
                
                cell.currentStatusLbl.text = "\(EnquiryStages.getStageType(searchId: self.enquiryObject?.enquiryStageId ?? 0)?.stageDescription ?? "NA")"
                if self.enquiryObject?.enquiryStageId == 5{
                    cell.currentStatusLbl.text = "\(EnquiryInnerStages.getStageType(searchId: self.enquiryObject?.innerEnquiryStageId ?? 0)?.stageDescription ?? "NA")"
                    
                }
                
                    cell.nextStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (self.enquiryObject?.enquiryStageId ?? 0) + 1)?.stageDescription ?? "NA")"
                if self.enquiryObject!.enquiryStageId == 3 && self.enquiryObject?.productStatusId == 2 {
                    cell.nextStatusLbl.text = "\(AvailableProductStages.getStageType(searchId: (self.enquiryObject?.enquiryStageId ?? 0) + 4)?.stageDescription ?? "NA")"
                }
               
                if self.enquiryObject?.enquiryStageId == 5 && self.enquiryObject!.innerEnquiryStageId <= 4{
                    cell.nextStatusLbl.text = "\(EnquiryInnerStages.getStageType(searchId: (self.enquiryObject?.innerEnquiryStageId ?? 0) + 1)?.stageDescription ?? "NA")"
                    
                }
                
                if (self.enquiryObject?.isBlue ?? false == true) && (self.enquiryObject?.enquiryStageId == 3 || self.enquiryObject?.enquiryStageId == 9){
                    cell.actionLbl.text = "Advance payment Awaiting"
                }else {
                    cell.actionLbl.text = ""
                }
                if self.isClosed {
                    row.hidden = true
                }
            })
            
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
            
            <<< AcceptedInvoiceRow() {
                $0.cell.height = { 120.0 }
                $0.tag = "View Invoice & Approve Advance Payment"
                if User.loggedIn()?.refRoleId == "1"  && enquiryObject!.enquiryStageId >= 3{
                    $0.hidden = false
                }
                else {
                    $0.hidden = true
                }
                $0.cell.tag = 3
                $0.cell.delegate = self
//
                if (enquiryObject!.isBlue){
                    $0.cell.approvePaymentButton.isHidden = false
                }
                else {
                    $0.cell.approvePaymentButton.isHidden = true
                    $0.cell.height = { 90.0 }
                }
            }.cellUpdate({ (cell, row) in
                if self.enquiryObject!.enquiryStageId >= 3 && User.loggedIn()?.refRoleId == "1"{
                    cell.row.hidden = false
                }
                else{
                    cell.row.hidden = true
                }
                 cell.tag = 3
                if (self.enquiryObject!.isBlue){
                    cell.approvePaymentButton.isHidden = false
                }
                else {
                    cell.approvePaymentButton.isHidden = true
                    cell.height = { 90.0 }
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check advance Payment receipt".localized
                $0.cell.valueLbl.text = "View"

                $0.cell.contentView.backgroundColor = UIColor().EQPurpleBg()
                $0.cell.titleLbl.textColor = UIColor().EQPurpleText()
                $0.cell.valueLbl.textColor = UIColor().EQPurpleText()
                if User.loggedIn()?.refRoleId == "1" && enquiryObject!.enquiryStageId >= 4  {
                    $0.hidden = false
                }
                else {
                    $0.hidden = true
                }
            }.onCellSelection({ (cell, row) in
                let storyboard = UIStoryboard(name: "Payment", bundle: nil)
                let vc1 = storyboard.instantiateViewController(withIdentifier: "PaymentArtistController") as! PaymentArtistController
                vc1.enquiryObject = self.enquiryObject
                vc1.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc1, animated: true)
            }).cellUpdate({ (cell, row) in
                if User.loggedIn()?.refRoleId == "1" && self.enquiryObject!.enquiryStageId >= 4  {
                    cell.row.hidden = false
                }
                else {
                    cell.row.hidden = true
                }
            })
            
            <<< TransactionReceiptRow() {
                $0.cell.height = { 120.0 }
                $0.cell.delegate = self
                $0.tag = "UploadReceipt"
                $0.cell.tag = 100
                $0.cell.viewProformaInvoiceBtn.setTitle("View\nPro forma\nInvoice", for: .normal)
                if User.loggedIn()?.refRoleId == "1"  {
                    $0.hidden = true
                }else if ( enquiryObject?.isPiSend == 1 || enquiryObject!.enquiryStageId >= 3){
                    $0.hidden = false
                }
                else {
                    $0.hidden = true
                }
                if self.enquiryObject?.productStatusId == 2 || self.enquiryObject!.isBlue || enquiryObject!.enquiryStageId > 3 {
                    $0.cell.uploadReceiptBtn.isHidden = true
                    $0.cell.height = { 80.0 }
                }
            }
            
            <<< ProFormaInvoiceRow() {
                $0.cell.height = { 150.0 }
                $0.cell.delegate = self
                $0.tag = "CreatePI"
                $0.cell.tag = 100
                if (enquiryObject?.enquiryStageId == 2 || enquiryObject?.enquiryStageId == 7){
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
                
                if User.loggedIn()?.refRoleId == "2" || isClosed || enquiryObject?.isPiSend == 1{
                    $0.hidden = true
                }
            }.cellUpdate({ (cell, row) in
                
                if self.enquiryObject?.enquiryStageId == 2 && User.loggedIn()?.refRoleId == "1"{
                    cell.row.hidden = false
                }
                else{
                    cell.row.hidden = true
                    cell.height = { 0.0 }
                }
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
                $0.cell.titleLbl.text = "Check MOQ".localized
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor().EQGreenBg()
                $0.cell.titleLbl.textColor = UIColor().EQGreenText()
                if User.loggedIn()?.refRoleId == "2" || isClosed
                {
                    $0.hidden = true
                }else {
                    $0.hidden = false
                }
            }.onCellSelection({ (cell, row) in
                let row1 = self.form.rowBy(tag: "createMOQ1")
                let row2 = self.form.rowBy(tag: "createMOQ2")
                let row3 = self.form.rowBy(tag: "createMOQ3")
                let row4 = self.form.rowBy(tag: "createMOQ4")
                let row5 = self.form.rowBy(tag: "createMOQ5")
                let row6 = self.form.rowBy(tag: "createMOQ6")
                if row1?.isHidden == true {
                    row1?.hidden = false
                    row2?.hidden = false
                    row3?.hidden = false
                    row4?.hidden = false
                    row5?.hidden = false
                    row6?.hidden = false
                }else {
                    row1?.hidden = true
                    row2?.hidden = true
                    row3?.hidden = true
                    row4?.hidden = true
                    row5?.hidden = true
                    row6?.hidden = true
                }
                row1?.evaluateHidden()
                row2?.evaluateHidden()
                row3?.evaluateHidden()
                row4?.evaluateHidden()
                row5?.evaluateHidden()
                row6?.evaluateHidden()
                self.form.allSections.first?.reload(with: .none)
            })
            <<< LabelRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "createMOQ1"
                $0.hidden = true
                if self.enquiryObject?.productType == "Custom Product" {
                    $0.title = "Fill in MOQ to bid for this enquiry"
                }else{
                    $0.title = "MOQ Details"
                }
                $0.cell.isUserInteractionEnabled = false
            }
            <<< RoundedTextFieldRow() {
                $0.cell.height = { 80.0 }
                $0.tag = "createMOQ2"
                $0.hidden = true
                $0.cell.titleLabel.text = "Minimum Quantity"
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "12"
                self.viewModel.minimumQuantity.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.minimumQuantity.value ?? ""
                self.viewModel.minimumQuantity.value = $0.cell.valueTextField.text
                $0.cell.valueTextField.textColor = .darkGray
            }.cellUpdate({ (cell, row) in
                if self.sentMOQ == 1{
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                }
                cell.valueTextField.maxLength = 2
                cell.valueTextField.text = self.viewModel.minimumQuantity.value ?? ""
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            
            <<< RoundedTextFieldRow() {
                $0.cell.height = { 80.0 }
                $0.tag = "createMOQ3"
                $0.hidden = true
                $0.cell.titleLabel.text = "Price per unit"
                $0.cell.valueTextField.keyboardType = .numberPad
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                $0.cell.valueTextField.textColor = .darkGray
                self.viewModel.pricePerUnit.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.pricePerUnit.value ?? ""
                self.viewModel.pricePerUnit.value = $0.cell.valueTextField.text
                
            }.cellUpdate({ (cell, row) in
                if self.sentMOQ == 1{
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                }
                cell.valueTextField.maxLength = 6
                cell.valueTextField.text = self.viewModel.pricePerUnit.value ?? ""
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            
            <<< RoundedActionSheetRow() {
                $0.tag = "createMOQ4"
                $0.cell.titleLabel.text = "Estimated Days"
                $0.cell.titleLabel.textColor = .black
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.options = allDeliveryTimes?.compactMap { $0.deliveryDesc }
                self.viewModel.estimatedDays.value = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getMOQ?.deliveryTimeId ?? 1)
                if let selectedTiming = self.viewModel.estimatedDays.value {
                    $0.cell.selectedVal = selectedTiming.deliveryDesc
                    $0.value = selectedTiming.deliveryDesc
                }
                $0.cell.actionButton.setTitle($0.value, for: .normal)
                $0.cell.delegate = self
                $0.cell.height = { 80.0 }
                $0.hidden = true
            }.onChange({ (row) in
                print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
                let selectedTimingObj = self.allDeliveryTimes?.filter({ (obj) -> Bool in
                    obj.deliveryDesc == row.value
                }).first
                self.viewModel.estimatedDays.value = selectedTimingObj
            }).cellUpdate({ (cell, row) in
                if self.sentMOQ == 1{
                    cell.options = []
                    cell.isUserInteractionEnabled = false
                }
                if let selectedTiming = self.viewModel.estimatedDays.value {
                    cell.selectedVal = selectedTiming.deliveryDesc
                    cell.row.value = selectedTiming.deliveryDesc
                }
                cell.actionButton.setTitle(cell.row.value, for: .normal)
            })
            
            <<< RoundedTextFieldRow() {
                $0.cell.height = { 80.0 }
                $0.tag = "createMOQ5"
                $0.hidden = true
                $0.cell.titleLabel.text = "Additional note"
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "Type your note here"
                self.viewModel.additionalNote.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.additionalNote.value ?? ""
                self.viewModel.additionalNote.value = $0.cell.valueTextField.text
                $0.cell.valueTextField.textColor = .darkGray
            }.cellUpdate({ (cell, row) in
                if self.sentMOQ == 1{
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                }
                cell.valueTextField.maxLength = 500
                cell.valueTextField.text = self.viewModel.additionalNote.value ?? ""
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
            })
            
            <<< SingleButtonRow() {
                $0.tag = "createMOQ6"
                $0.cell.singleButton.backgroundColor = UIColor().CEGreen()
                $0.cell.singleButton.setTitleColor(.white, for: .normal)
                $0.cell.singleButton.setTitle("Send MOQ", for: .normal)
                $0.cell.height = { 50.0 }
                $0.cell.delegate = self as SingleButtonActionProtocol
                $0.cell.tag = 101
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                if self.sentMOQ == 1{
                    cell.isHidden = true
                    cell.height = { 0.0 }
                }
            })
            
            <<< MOQSectionTitleRow() {
                $0.cell.height = { 44.0 }
                $0.tag = "Check MOQ Buyer"
                $0.cell.titleLbl.text = "Check MOQ".localized
                $0.cell.noOfUnitLbl.text = "70 pcs"
                $0.cell.costLbl.text = "Rs 1000"
                $0.cell.etaLbl.text = "100 days"
                $0.cell.contentView.backgroundColor = UIColor().EQGreenBg()
                $0.cell.titleLbl.textColor = UIColor().EQGreenText()
                $0.cell.noOfUnitLbl.textColor = UIColor().EQGreenText()
                $0.cell.costLbl.textColor = UIColor().EQGreenText()
                $0.cell.etaLbl.textColor = UIColor().EQGreenText()
                if (enquiryObject?.isMoqSend == 1 && User.loggedIn()?.refRoleId == "2"){
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
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
            }).cellUpdate({ (cell, row) in
                if (self.enquiryObject?.enquiryStageId == 2 && User.loggedIn()?.refRoleId == "2"){
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
                if self.getMOQs != nil{
                    cell.noOfUnitLbl.text = "\(self.getMOQs!.moq) pcs"
                    cell.costLbl.text = "Rs " + self.getMOQs!.ppu!
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: self.getMOQs!.deliveryTimeId)!.days
                    cell.etaLbl.text = "\(ETAdays) days"
                }
                
            })
            <<< MOQValueRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "MOQ1"
                $0.cell.unitLbl.text = "MOQ"
                $0.cell.valueLbl.text = "70 pcs"
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                if self.getMOQs != nil{
                    cell.valueLbl.text = "\(self.getMOQs!.moq) pcs"
                }
                
            })
            
            <<< MOQValueRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "MOQ2"
                $0.cell.unitLbl.text = "Price/unit(or m)"
                $0.cell.valueLbl.text = "Rs 1000"
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                if self.getMOQs != nil{
                    cell.valueLbl.text = "Rs " + self.getMOQs!.ppu!
                }
            })
            
            <<< MOQValueRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "MOQ3"
                $0.cell.unitLbl.text = "ETA Delivery"
                $0.cell.valueLbl.text = "100 days"
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                if self.getMOQs != nil{
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: self.getMOQs!.deliveryTimeId)!.days
                    cell.valueLbl.text = "\(ETAdays) days"
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check Product Details".localized
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
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check MOQ".localized
                $0.tag = "Check MOQs"
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor().EQGreenBg()
                $0.cell.titleLbl.textColor = UIColor().EQGreenText()
                if (enquiryObject?.isMoqSend == 1 || User.loggedIn()?.refRoleId == "1"){
                    $0.hidden = true
                }else {
                    $0.hidden = false
                }
            }.onCellSelection({ (cell, row) in
                let section = self.form.sectionBy(tag: "list MOQs")
                if section?.isEmpty == true {
                    self.listMOQsFunc()
                }else {
                    section?.removeAll()
                }
                section?.reload()
                
            }).cellUpdate({ (cell, row) in
                if (self.enquiryObject?.isMoqSend == 1 || User.loggedIn()?.refRoleId == "1"){
                    cell.isHidden = true
                }else {
                    cell.isHidden = false
                }
            })
            
            +++ Section(){ section in
                section.tag = "list MOQs"
        }
        
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    @objc func showOptions(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "", message: "Choose".localized, preferredStyle: .actionSheet)
        
        let chat = UIAlertAction.init(title: "Chat", style: .default) { (action) in
            self.goToChat()
        }
        alert.addAction(chat)
        
        let closeEnquiry = UIAlertAction.init(title: "Close Enquiry".localized, style: .default) { (action) in
            self.confirmAction("Warning".localized, "Are you sure you want to close this enquiry?".localized, confirmedCallback: { (action) in
                self.closeEnquiry?(self.enquiryObject?.entityID ?? 0)
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
        
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
                let service = ChatListService.init(client: client)
            if let enquiryId = enquiryObject?.enquiryId {
                service.initiateConversation(vc: self, enquiryId: enquiryId)
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func reloadFormData() {
        enquiryObject = realm?.objects(Enquiry.self).filter("%K == %@","entityID",enquiryObject?.entityID ?? 0).first
        if self.enquiryObject?.productStatusId == 2 || self.enquiryObject!.isBlue || enquiryObject!.enquiryStageId > 3 {
            let row = form.rowBy(tag: "UploadReceipt") as? TransactionReceiptRow
            row?.cell.uploadReceiptBtn.isHidden = true
            row?.cell.height = { 80.0 }
            self.form.allSections.first?.reload(with: .none)
        }
        if User.loggedIn()?.refRoleId == "1" && self.enquiryObject!.enquiryStageId >= 4  {
            let row = form.rowBy(tag: "Check advance Payment receipt")
            row?.hidden = false
            row?.evaluateHidden()
            self.form.allSections.first?.reload(with: .none)
        }
        if self.enquiryObject!.enquiryStageId >= 3 && User.loggedIn()?.refRoleId == "1"{
            let row = form.rowBy(tag: "View Invoice & Approve Advance Payment")
            row?.hidden = false
            row?.evaluateHidden()
            self.form.allSections.first?.reload(with: .none)
        }
//        if User.loggedIn()?.refRoleId == "1" && self.enquiryObject?.enquiryStageId == 4{
//            let row = form.rowBy(tag: "Start Production Stage")
//            row?.hidden = false
//            row?.evaluateHidden()
//            self.form.allSections.first?.reload(with: .none)
//        }
//        if User.loggedIn()?.refRoleId == "1" && self.enquiryObject?.enquiryStageId == 5 {
//            let row = form.rowBy(tag: "Production Stages Progrees")
//            row?.hidden = false
//            row?.evaluateHidden()
//            self.form.allSections.first?.reload(with: .none)
//        }
        if self.enquiryObject?.enquiryStageId == 2 && User.loggedIn()?.refRoleId == "1"{
            let row = form.rowBy(tag: "CreatePI")
            row?.hidden = false
            row?.evaluateHidden()
            self.form.allSections.first?.reload(with: .none)
        }
        if (self.enquiryObject?.enquiryStageId == 2 && User.loggedIn()?.refRoleId == "2"){
            let row = form.rowBy(tag: "Check MOQ Buyer")
            row?.hidden = false
            row?.evaluateHidden()
            self.form.allSections.first?.reload(with: .none)
        }
        
        form.allRows .forEach { (row) in
            row.reload()
            // row.updateCell()
        }
        
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    func listMOQsFunc() {
        var valid = 0
        if listMOQs != [] &&  User.loggedIn()?.refRoleId == "2" {
            let section = self.form.sectionBy(tag: "list MOQs")
            if section?.isEmpty == true{
                valid = 1
            }

            if  let  listMOQSection = self.form.sectionBy(tag: "list MOQs") {
            
            listMOQSection <<< LabelRow() {
                $0.cell.height = { 25.0 }
                $0.tag = "list MOQs label"
                if self.enquiryObject?.productType == "Custom Product" {
                    $0.title = "Accept MOQ from this list"
                }else{
                    $0.title = "Accept MOQ"
                }
                $0.cell.isUserInteractionEnabled = false
            }
            
            if self.enquiryObject?.productType == "Custom Product" {
                listMOQSection <<< MOQSortButtonsRow() {
                    //   $0.hidden = true
                    $0.cell.height = { 30.0 }
                    $0.tag = "sort buttons row"
                    $0.cell.height = { 50.0 }
                    $0.cell.delegate = self as MOQSortButtonsActionProtocol
//                    $0.cell.quantityButton.tag = 201
//                    $0.cell.priceButton.tag = 201
//                    $0.cell.ETAButton.tag = 201
                    $0.cell.tag = 201
                    
                }.cellUpdate({ (cell, row) in
                    cell.quantityButton.setTitle("Qnty", for: .normal)
                    cell.priceButton.setTitle("Price", for: .normal)
                    cell.ETAButton.setTitle("ETA", for: .normal)
                })
            }
            
            let showMOQ = listMOQs!
            showMOQ.forEach({ (obj) in
                listMOQSection <<< MOQSectionTitleRow() {
                    $0.cell.height = { 44.0 }
                    $0.cell.titleLbl.text = (obj.brand ?? "") + "\n" + (obj.clusterName ?? "")
                    $0.cell.noOfUnitLbl.text = "\(obj.moq!.moq) pcs"
                    $0.cell.costLbl.text = "₹ " + (obj.moq?.ppu ?? "")
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: obj.moq!.deliveryTimeId )?.days
                    $0.cell.etaLbl.text = "\(ETAdays!) days"
                    $0.cell.titleLbl.textColor = .systemBlue
                    $0.cell.noOfUnitLbl.textColor = UIColor().EQGreenText()
                    $0.cell.costLbl.textColor = UIColor().EQGreenText()
                    $0.cell.etaLbl.textColor = UIColor().EQGreenText()
                    
                }.onCellSelection({ (cell, row) in
                    let row = self.form.rowBy(tag: "\(obj.artisanId)")
                    let button1 = self.form.rowBy(tag: "\(obj.moq!.id)")
                    if row?.isHidden == true {
                        row?.hidden = false
                        button1?.hidden = false
                    }else {
                        row?.hidden = true
                        button1?.hidden = true
                    }
                    row?.evaluateHidden()
                    button1?.evaluateHidden()
                    listMOQSection.reload()
                })
                    
                    <<< MOQSelectedDetailsRow() {
                        $0.cell.height = { 100.0 }
                        $0.cell.delegate = self as MOQButtonActionProtocol
                        $0.cell.tag = obj.artisanId
                        $0.hidden = true
                        $0.tag = "\(obj.artisanId)"
                        let date = Date().ttceFormatter(isoDate: "\(obj.moq?.modifiedOn)")
                        $0.cell.label1.text = "Received on \(date)"
                        $0.cell.label2.text = "Notes from Artisan"
                        $0.cell.label3.text = obj.moq?.additionalInfo ?? ""
                        $0.cell.imageButton.isUserInteractionEnabled = false
                        //    $0.cell.detailsButton.onchange
                        let name = obj.logo ?? ""
                        let userID = obj.artisanId
                        let url = URL(string: KeychainManager.standard.imageBaseURL + "/User/\(userID)/CompanyDetails/Logo/\(name)")
                        URLSession.shared.dataTask(with: url!) { data, response, error in
                            // do your stuff here...
                            DispatchQueue.main.async {
                                // do something on the main queue
                                if error == nil {
                                    if let finalData = data {
                                        let row = self.form.rowBy(tag: "\(obj.artisanId)") as? MOQSelectedDetailsRow
                                        row?.cell.imageButton.setImage(UIImage.init(data: finalData), for: .normal)
                                    }
                                }
                            }
                        }.resume()
                    }
                    
                    <<< SingleLabelRow() {
                        $0.cell.height = { 40.0 }
                        $0.cell.acceptLabel.text = "Accept"
                        
                        $0.tag = "\(obj.moq!.id)"
                        $0.hidden = true
                    }.onCellSelection({ (cell, row) in
                        print("on selection worked")
                        self.viewModel.acceptMOQInfo.value = obj
                        self.view.showAcceptMOQView(controller: self, getMOQs: obj)
                    })
            })
                if valid == 1{
                    self.form.sectionBy(tag: "list MOQs")?.reload()
                }
            
        }
        }
    }
    
    func reloadMOQ() {
        DispatchQueue.main.async(){
            let row1 = self.form.rowBy(tag: "createMOQ1")
            let row2 = self.form.rowBy(tag: "createMOQ2")
            let row3 = self.form.rowBy(tag: "createMOQ3")
            let row4 = self.form.rowBy(tag: "createMOQ4")
            let row5 = self.form.rowBy(tag: "createMOQ5")
            let row6 = self.form.rowBy(tag: "createMOQ6")
            row1?.reload()
            row2?.reload()
            row3?.reload()
            row4?.reload()
            row5?.reload()
            row6?.reload()
            self.form.allSections.first?.reload(with: .none)
        }
    }
    
    func reloadBuyerMOQ() {
        DispatchQueue.main.async(){
            let row1 = self.form.rowBy(tag: "Check MOQ Buyer")
            let row2 = self.form.rowBy(tag: "MOQ1")
            let row3 = self.form.rowBy(tag: "MOQ2")
            let row4 = self.form.rowBy(tag: "MOQ3")
            row1?.reload()
            row2?.reload()
            row3?.reload()
            row4?.reload()
            self.form.allSections.first?.reload(with: .none)
            self.hideLoading()
        }
    }
    
    func assignMOQ() {
        if let MOQ = getMOQ {
            viewModel.additionalNote.value = MOQ.additionalInfo
            viewModel.estimatedDays.value = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: MOQ.deliveryTimeId)
            viewModel.minimumQuantity.value = "\(MOQ.moq)"
            viewModel.pricePerUnit.value = MOQ.ppu
            sentMOQ = 1
            let row = self.form.rowBy(tag: "createMOQ6")
            row?.hidden = true
            row?.evaluateHidden()
            self.form.allSections.first?.reload(with: .none)
            reloadMOQ()
        }
        else{
            print("novalue")
        }
    }
}

class CreateMOQModel {
    var minimumQuantity = Observable<String?>(nil)
    var pricePerUnit = Observable<String?>(nil)
    var estimatedDays = Observable<EnquiryMOQDeliveryTimes?>(nil)
    var additionalNote = Observable<String?>(nil)
    var acceptMOQInfo = Observable<GetMOQs?>(nil)
}

extension BuyerEnquiryDetailsController:  MOQButtonActionProtocol, SingleButtonActionProtocol, MOQSortButtonsActionProtocol, InvoiceButtonProtocol, AcceptedInvoiceRowProtocol {
    func approvePaymentButtonSelected(tag: Int) {
        switch tag{
        case 3:
            let storyboard = UIStoryboard(name: "Payment", bundle: nil)
            let vc1 = storyboard.instantiateViewController(withIdentifier: "PaymentArtistController") as! PaymentArtistController
            vc1.enquiryObject = self.enquiryObject
            vc1.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc1, animated: true)
            
        default:
            print("PaymentArtistBtnSelected Not WORKING")
        }
    }
    
    func viewInvoiceButtonSelected(tag: Int) {
        switch tag{
        case 3:
            self.showLoading()
            self.viewPI?(1)
        default:
            print("do nothing")
        }
    }
    
    
    func createSendInvoiceBtnSelected(tag: Int) {
        switch tag{
        case 100:
            let client = try! SafeClient(wrapping: CraftExchangeClient())
            let vc1 = EnquiryDetailsService(client: client).piCreate(enquiryId: self.enquiryObject!.enquiryId, enquiryObj: self.enquiryObject!, orderObj: nil) as! InvoiceController
            vc1.modalPresentationStyle = .fullScreen
            vc1.enquiryObject = self.enquiryObject
            
            print("PI WORKING")
            self.navigationController?.pushViewController(vc1, animated: true)
            print("createSendInvoiceBtnSelected WORKING")
        default:
            print("NOt Working PI")
        }
    }
    
    func singleButtonSelected(tag: Int) {
        switch tag {
        case 101:
            self.showLoading()
            self.sendMOQ?()
        default:
            print("do nothing")
        }
    }
    
    func detailsButtonSelected(tag: Int) {
        let showMOQ = listMOQs!
        showMOQ.forEach({ (obj) in
            switch tag {
                
            case obj.artisanId :
                let vc = CustomMOQArtisanDetailsController.init(style: .plain)
                vc.enquiryObject = self.enquiryObject
                vc.getMOs = obj
                self.navigationController?.pushViewController(vc, animated: true)
                print(obj.artisanId)
            default:
                print("do nothing")
            }
            
        })
        
    }
    
    func quantityButtonSelected(tag: Int) {
        
        switch tag {
        case 201:
            let row = self.form.rowBy(tag: "sort buttons row") as! MOQSortButtonsRow
            if row.cell.quantityDescending == true {
                if listMOQs != nil {
                    listMOQs = listMOQs?.sorted(by: { (getmoq1, getmoq2) -> Bool in
                       return getmoq1.moq!.moq > getmoq2.moq!.moq
                    })
                }
                let  listMOQSection = self.form.sectionBy(tag: "list MOQs")
                listMOQSection?.removeAll()
                self.listMOQsFunc()
                print("descending")
            }else{
                if listMOQs != nil {
                    listMOQs = listMOQs?.sorted(by: { (getmoq1, getmoq2) -> Bool in
                       return getmoq1.moq!.moq < getmoq2.moq!.moq
                    })
                }
                let  listMOQSection = self.form.sectionBy(tag: "list MOQs")
                listMOQSection?.removeAll()
                self.listMOQsFunc()
                print("ascending")
            }
            
            
            
            
        default:
            print("do nothing")
        }
    }
    
    func priceButtonSelected(tag: Int) {
        switch tag {
        case 201:
            let row = self.form.rowBy(tag: "sort buttons row") as! MOQSortButtonsRow
            if row.cell.priceDescending == true {
                if listMOQs != nil {
                               listMOQs = listMOQs?.sorted(by: { (getmoq1, getmoq2) -> Bool in
                                  
                                   var success = false
                                   
                                   if let ppu1 =  Int(getmoq1.moq!.ppu!), let ppu2 =  Int(getmoq2.moq!.ppu!) {
                                       success = ppu1 > ppu2
                                   }
                                   return success
                               })
                           }
                let  listMOQSection = self.form.sectionBy(tag: "list MOQs")
                listMOQSection?.removeAll()
                self.listMOQsFunc()
            }else{
                if listMOQs != nil {
                               listMOQs = listMOQs?.sorted(by: { (getmoq1, getmoq2) -> Bool in
                                  
                                   var success = false
                                   
                                   if let ppu1 =  Int(getmoq1.moq!.ppu!), let ppu2 =  Int(getmoq2.moq!.ppu!) {
                                       success = ppu1 < ppu2
                                   }
                                   return success
                               })
                           }
                let  listMOQSection = self.form.sectionBy(tag: "list MOQs")
                listMOQSection?.removeAll()
                self.listMOQsFunc()
            }

           
            
        default:
            print("do nothing")
        }
    }
    
    func ETAButtonSelected(tag: Int) {
        switch tag {
        case 201:
            let row = self.form.rowBy(tag: "sort buttons row") as! MOQSortButtonsRow
            if row.cell.daysDescending == true {
               
                    if listMOQs != nil {
                        listMOQs = listMOQs?.sorted(by: { (getmoq1, getmoq2) -> Bool in
                            var success = false
                            
                            if let days1 =  EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getmoq1.moq!.deliveryTimeId )?.days, let days2 =  EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getmoq2.moq!.deliveryTimeId )?.days {
                                success = days1 > days2
                            }
                            return success
                        })
                    }
                let  listMOQSection = self.form.sectionBy(tag: "list MOQs")
                listMOQSection?.removeAll()
                self.listMOQsFunc()
                
            }else{
                    if listMOQs != nil {
                        if listMOQs != nil {
                            listMOQs = listMOQs?.sorted(by: { (getmoq1, getmoq2) -> Bool in
                                var success = false
                                
                                if let days1 =  EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getmoq1.moq!.deliveryTimeId )?.days, let days2 =  EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getmoq2.moq!.deliveryTimeId )?.days {
                                    success = days1 < days2
                                }
                                return success
                            })
                        }
                    }
                let  listMOQSection = self.form.sectionBy(tag: "list MOQs")
                listMOQSection?.removeAll()
                self.listMOQsFunc()
                }
                
        default:
            print("do nothing")
        }
    }
    
}
extension BuyerEnquiryDetailsController: MOQAcceptViewProtocol, MOQAcceptedViewProtocol, AcceptedPIViewProtocol, paymentButtonProtocol  {
    func viewProformaInvoiceBtnSelected(tag: Int) {
        self.showLoading()
        self.viewPI?(1)
    }
    
    func RejectBtnSelected(tag: Int) {
        print("do nothing")
    }
    
    func paymentBtnSelected(tag: Int) {
        print("do nothing")
        switch tag{
        case 100:
            if self.enquiryObject!.isBlue || self.enquiryObject!.enquiryStageId >= 4{
                let client = try? SafeClient(wrapping: CraftExchangeClient())
                let vc1 = EnquiryDetailsService(client: client!).createPaymentScene(enquiryId: self.enquiryObject!.enquiryId) as! PaymentUploadController
                vc1.enquiryObject = self.enquiryObject
                vc1.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc1, animated: true)
            }
            else{
                let storyboard = UIStoryboard(name: "Payment", bundle: nil)
                let vc1 = storyboard.instantiateViewController(withIdentifier: "PaymentBuyerOneController") as! PaymentBuyerOneController
                vc1.enquiryObject = self.enquiryObject
                vc1.PI = self.PI
                vc1.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc1, animated: true)
                print("uploadReceiptBtnSelected")
            }
        default:
            print("uploadReceiptBtnSelected Not WORKING")
        }
    }
    
    func backButtonSelected() {
        self.view.hideAcceptedPIView()
    }
    
    func downloadButtonSelected() {
        self.downloadPI?()
    }
    
    
    func cancelButtonSelected() {
        self.view.hideAcceptMOQView()
    }
    
    func acceptMOQButtonSelected() {
        self.showLoading()
        self.acceptMOQ?()
    }
    
    func enquiryChatButtonSelected() {
        self.goToChat()
    }
    
    func okButtonSelected() {
        self.reloadBuyerMOQ()
        self.form.allSections.first?.reload(with: .none)
        self.view.hideAcceptedMOQView()
        viewWillAppear?()
    }
    
}

//extension BuyerEnquiryDetailsController: MarkCompleteAndNextProtocol, StartstageProtocol {
//
//
//    func MarkProgressSelected(tag: Int) {
//        self.showLoading()
//        let client = try! SafeClient(wrapping: CraftExchangeClient())
//        let service = EnquiryDetailsService.init(client: client)
//        service.changeInnerStageFunc(vc: self, enquiryId: enquiryObject!.enquiryId, stageId: enquiryObject!.enquiryStageId, innerStageId: enquiryObject!.innerEnquiryStageId)
//    }
//
//    func MarkCompleteNextSelected(tag: Int) {
//        self.showLoading()
//        let client = try! SafeClient(wrapping: CraftExchangeClient())
//        let service = EnquiryDetailsService.init(client: client)
//        if enquiryObject!.innerEnquiryStageId == 5{
//            service.changeInnerStageFunc(vc: self, enquiryId: enquiryObject!.enquiryId, stageId: 6, innerStageId: 0)
//        }
//        else{
//            service.changeInnerStageFunc(vc: self, enquiryId: enquiryObject!.enquiryId, stageId: enquiryObject!.enquiryStageId, innerStageId: enquiryObject!.innerEnquiryStageId + 1)
//        }
//
//    }
//
//    func StartstageBtnSelected(tag: Int) {
//        self.showLoading()
//        let client = try! SafeClient(wrapping: CraftExchangeClient())
//        let service = EnquiryDetailsService.init(client: client)
//        service.changeInnerStageFunc(vc: self, enquiryId: enquiryObject!.enquiryId, stageId: 5, innerStageId: 1)
//    }
//
//
//}
