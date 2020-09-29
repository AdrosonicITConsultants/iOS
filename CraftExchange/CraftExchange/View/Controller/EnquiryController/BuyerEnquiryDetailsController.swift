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
    lazy var viewModel = CreateMOQModel()
    var allDeliveryTimes: Results<EnquiryMOQDeliveryTimes>?
    // var sendMOQ: ((_ enquiryId: Int, _ additionalInfo: String, _ deliveryTimeId: Int, _ moq: Int, _ ppu: String) -> ())?
    var sendMOQ: (() -> ())?
    var acceptMOQ: (() -> ())?
    var sentMOQ: Int = 0
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
        checkMOQ?()
        checkMOQs?()
        
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
                $0.title = "Enquiry Details"
            }
            <<< StatusRow() {
                $0.cell.height = { 110.0 }
                $0.cell.previousStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (enquiryObject?.enquiryStageId ?? 0) - 1)?.stageDescription ?? "NA")"
                $0.cell.currentStatusLbl.text = "\(EnquiryStages.getStageType(searchId: enquiryObject?.enquiryStageId ?? 0)?.stageDescription ?? "NA")"
                $0.cell.nextStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (enquiryObject?.enquiryStageId ?? 0) + 1)?.stageDescription ?? "NA")"
                if (enquiryObject?.isBlue ?? false == true) && (enquiryObject?.enquiryStageId == 4 || enquiryObject?.enquiryStageId == 9){
                    $0.cell.actionLbl.text = "Advance payment Awaiting"
                }else {
                    $0.cell.actionLbl.text = ""
                }
                if isClosed {
                    $0.hidden = true
                }
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
            <<< ProFormaInvoiceRow() {
                $0.cell.height = { 150.0 }
                if (enquiryObject?.enquiryStageId == 2 || enquiryObject?.enquiryStageId == 7){
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
                if User.loggedIn()?.refRoleId == "2" || isClosed {
                    $0.hidden = true
                }
            }
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
                $0.cell.titleLbl.text = "Check MOQ"
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor().EQGreenBg()
                $0.cell.titleLbl.textColor = UIColor().EQGreenText()
                if (User.loggedIn()?.refRoleId == "2"){
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
                //  $0.cell.valueTextField.keyboardType = .numberPad
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
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "123456"
                self.viewModel.pricePerUnit.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
                $0.cell.valueTextField.text = self.viewModel.pricePerUnit.value ?? ""
                self.viewModel.pricePerUnit.value = $0.cell.valueTextField.text
                $0.cell.valueTextField.textColor = .darkGray
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
                cell.valueTextField.maxLength = 40
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
                $0.cell.titleLbl.text = "Check MOQ"
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
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check MOQ"
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
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
    func listMOQsFunc() {
        if listMOQs != [] &&  User.loggedIn()?.refRoleId == "2" {
            
            let  listMOQSection = self.form.sectionBy(tag: "list MOQs")!
            
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
                    $0.cell.quantityButton.tag = 201
                    $0.cell.priceButton.tag = 201
                    $0.cell.ETAButton.tag = 201
                    
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
                    $0.cell.titleLbl.text = obj.brand! + "\n" + obj.clusterName!
                    $0.cell.noOfUnitLbl.text = "\(obj.moq!.moq) pcs"
                    $0.cell.costLbl.text = "₹ " + obj.moq!.ppu!
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: obj.moq!.deliveryTimeId)!.days
                    $0.cell.etaLbl.text = "\(ETAdays) days"
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
                        let date = Date().ttceFormatter(isoDate: "\(obj.moq!.modifiedOn!)")
                        $0.cell.label1.text = "Received on \(date)"
                        $0.cell.label2.text = "Notes from Artisan"
                        $0.cell.label3.text = obj.moq!.additionalInfo!
                        $0.cell.imageButton.isUserInteractionEnabled = false
                        //    $0.cell.detailsButton.onchange
                        let name = obj.logo!
                        let userID = obj.artisanId
                        let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/User/\(userID)/CompanyDetails/Logo/\(name)")
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
            self.form.sectionBy(tag: "list MOQs")?.reload()
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

extension BuyerEnquiryDetailsController:  MOQButtonActionProtocol, SingleButtonActionProtocol, MOQSortButtonsActionProtocol {
    
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
            print("do nothing")
        default:
            print("do nothing")
        }
    }
    
    func priceButtonSelected(tag: Int) {
        switch tag {
        case 201:
            print("do nothing")
        default:
            print("do nothing")
        }
    }
    
    func ETAButtonSelected(tag: Int) {
        switch tag {
        case 201:
            print("do nothing")
        default:
            print("do nothing")
        }
    }
    
}
extension BuyerEnquiryDetailsController: MOQAcceptViewProtocol, MOQAcceptedViewProtocol  {
    
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
    }
    
}
