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
    var enquiryObject: AdminEnquiry?
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
    var sendMOQ: (() -> ())?
    var acceptMOQ: (() -> ())?
    var sentMOQ: Int = 0
    var viewPI: (() -> ())?
    var downloadPI: (() -> ())?
    var isMOQNeedToAccept: Int = 0
    var showUserDetails: ((_ isAdmin: Bool) -> ())?
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
        getPI?()
        var shouldShowOption = false
        
        if User.loggedIn()?.refRoleId == "1" {
            shouldShowOption = false
        }else {
            if enquiryObject?.currenStageId ?? 0 > 3 {
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
            <<< AdminEnquiryDetailRow() {
                $0.cell.height = { 590.0 }
                if let eqObj = enquiryObject {
                    $0.cell.configureCell(eqObj)
                }
            }
            <<< LabelRow(){
                $0.title = "Enquiry Details"
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
            })
            <<< EnquiryClosedRow() {
                $0.cell.height = { 110.0 }
                if enquiryObject?.currenStageId == 10 {
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
            
            <<< MOQSectionTitleRow() {
                $0.cell.height = { 44.0 }
                $0.tag = "Check MOQ Buyer"
                $0.cell.titleLbl.text = "Check MOQ"
                $0.cell.noOfUnitLbl.text = "70 pcs"
                $0.cell.costLbl.text = "Rs 1000"
                $0.cell.etaLbl.text = "100 days"
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.noOfUnitLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.costLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.etaLbl.textColor = UIColor.init(named: "AdminGreenText")
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
                cell.backgroundColor = .black
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
                cell.backgroundColor = .black
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
                cell.backgroundColor = .black
                if self.getMOQs != nil{
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: self.getMOQs!.deliveryTimeId)!.days
                    cell.valueLbl.text = "\(ETAdays) days"
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check PI".localized
                $0.cell.valueLbl.text = "View".localized
                $0.cell.contentView.backgroundColor = UIColor.init(named: "ArmyGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "ArmyGreenText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "ArmyGreenText")
                if self.enquiryObject?.currenStageId ?? 0 >= 3 {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }.onCellSelection({ (cell, row) in
                self.showLoading()
                self.viewPI?()
            }).cellUpdate({ (cell, row) in
                if self.enquiryObject?.currenStageId ?? 0 >= 3 {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check Product Details"
                $0.cell.valueLbl.text = "\(enquiryObject?.tag ?? "View")"
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminBlueBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminBlueText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminBlueText")
            }.onCellSelection({ (cell, row) in
                if self.enquiryObject?.customProductId != 0 {
                    self.showCustomProduct?()
                }else if self.enquiryObject?.productHistoryId != 0 {
                    self.showHistoryProductDetails?()
                }else {
                    self.showProductDetails?()
                }
            })
        
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check artisan's details"
                $0.cell.valueLbl.text = "Brand: \(enquiryObject?.artisanBrand ?? "NA")"
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminPurpleBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminPurpleText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminPurpleText")
            }.onCellSelection({ (cell, row) in
                self.showUserDetails?(true)
            })
                        
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check buyer's details"
                $0.cell.valueLbl.text = "Brand: \(enquiryObject?.buyerBrand ?? "NA")"
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminGreenText")
            }.onCellSelection({ (cell, row) in
                self.showUserDetails?(false)
            })
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
        enquiryObject = realm?.objects(AdminEnquiry.self).filter("%K == %@","entityID",enquiryObject?.entityID ?? 0).first
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
                if self.enquiryObject?.customProductId != 0 {
                    $0.title = "Accept MOQ from this list"
                }else{
                    $0.title = "Accept MOQ"
                }
                $0.cell.isUserInteractionEnabled = false
            }
            
            if self.enquiryObject?.customProductId != 0 {
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
}

class CreateMOQModel {
    var minimumQuantity = Observable<String?>(nil)
    var pricePerUnit = Observable<String?>(nil)
    var estimatedDays = Observable<EnquiryMOQDeliveryTimes?>(nil)
    var additionalNote = Observable<String?>(nil)
    var acceptMOQInfo = Observable<GetMOQs?>(nil)
}

extension BuyerEnquiryDetailsController:  MOQButtonActionProtocol, MOQSortButtonsActionProtocol, AcceptedInvoiceRowProtocol {
    func viewInvoiceButtonSelected(tag: Int) {
        switch tag{
        case 100:
            self.showLoading()
            self.viewPI?()
        default:
            print("do nothing")
        }
    }
    
    func detailsButtonSelected(tag: Int) {
        /*let showMOQ = listMOQs!
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
        */
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

extension BuyerEnquiryDetailsController: MOQAcceptViewProtocol, MOQAcceptedViewProtocol, AcceptedPIViewProtocol  {
    
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
    }
    
}
