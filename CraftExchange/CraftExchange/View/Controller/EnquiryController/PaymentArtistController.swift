//
//  PaymentArtistController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 01/10/20.
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

class PaymentArtistController: FormViewController{
    var enquiryObject: Enquiry?
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    var showCustomProduct: (() -> ())?
    var showProductDetails: (() -> ())?
    var finalPaymnetDetails: FinalPaymentDetails?
    var showHistoryProductDetails: (() -> ())?
    var closeEnquiry: ((_ enquiryId: Int) -> ())?
    let realm = try? Realm()
    var status: Int?
    var revisedAdvancePayment: RevisedAdvancedPayment?
    var revisedAdvancePaymentId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
            let service = EnquiryDetailsService.init(client: client)
            
            if orderObject?.revisedAdvancePaymentId == 3 {
                service.downloadAndViewReceipt(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0, typeId: 3)
            }
            else if orderObject?.enquiryStageId == 8 {
                service.downloadAndViewReceipt(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0, typeId: 2)
            }else{
                service.advancePaymentStatus(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0)
                service.downloadAndViewReceipt(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0, typeId: 1)
            }
        }
        
        
        form
            +++ Section()
            
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 200.0 }
                $0.cell.selectionStyle = .none
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
               
                $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "\(enquiryObject?.totalAmount ?? 0)" : "NA"
                if orderObject != nil {
                    $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "\(orderObject?.totalAmount ?? 0)" : "NA"
                }
                
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let date = orderObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
                }
                $0.loadRowImage(orderObject: orderObject, enquiryObject: enquiryObject, vc: self)
            }
            <<< LabelRow(){
                $0.title = "Payment Receipt: ".localized
            }
            <<< ArtistReceitImgRow(){
                $0.cell.height = { 325.0 }
                //               $0.cell.delegate = self
                $0.tag = "PaymentArtist-1"
                $0.cell.tag = 4
                if orderObject?.revisedAdvancePaymentId == 3{
                    $0.cell.AmountLabel.text = "Pending advance paid by buyer: ".localized +  "\(revisedAdvancePayment?.pendingAmount ?? 0)"
                }
                if orderObject?.enquiryStageId == 8 {
                    $0.cell.AmountLabel.text = "Final amount paid by buyer: ".localized +  "\(finalPaymnetDetails?.payableAmount ?? 0)"
                }
            }
            
            <<< ApprovePaymentRow() {
                $0.cell.height = { 150.0}
                $0.cell.ApproveBTn.tag = 5
                $0.tag = "PaymentArtist-2"
                $0.cell.tag = 5
                if orderObject?.enquiryStageId == 8{
                    $0.cell.ApproveBTn.setTitle("Approve Final Payment by Buyer", for: .normal)
                }
                if orderObject?.revisedAdvancePaymentId == 3{
                    $0.cell.ApproveBTn.setTitle("Approve pending advance by Buyer", for: .normal)
                }
                $0.cell.delegate = self
                if enquiryObject?.enquiryStageId ?? orderObject?.enquiryStageId ?? 0 >= 4{
                    $0.hidden = true
                }
                if orderObject?.enquiryStageId == 8{
                    $0.hidden = false
                }
                if orderObject?.revisedAdvancePaymentId == 3{
                    $0.hidden = false
                }
                
        }
        
    }
}
extension PaymentArtistController: ApproveButtonProtocol {
    func RejectBtnSelected(tag: Int) {
        switch tag{
        case 5:
            self.status = 2
            self.showLoading()
            if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
                let service = EnquiryDetailsService.init(client: client)
                if let order = self.orderObject {
                    if order.revisedAdvancePaymentId == 3 {
                        service.validatePaymentFunc(vc: self,typeId: 3, enquiryId: order.enquiryId, status: self.status!)
                    }else{
                        service.validatePaymentFunc(vc: self,typeId: 2, enquiryId: order.enquiryId, status: self.status!)
                    }
                }else if let enquiry = self.enquiryObject {
                    service.validatePaymentFunc(vc: self,typeId: 1, enquiryId: enquiry.enquiryId, status: self.status!)
                }
            }
        default:
            print("do nothing")
        }
    }
    
    func ApproveBtnSelected(tag: Int) {
        switch tag{
        case 5:
            self.status = 1
            self.showLoading()
            if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
                let service = EnquiryDetailsService.init(client: client)
                if let order = self.orderObject {
                    if order.revisedAdvancePaymentId == 3 {
                        service.validatePaymentFunc(vc: self,typeId: 3, enquiryId: order.enquiryId, status: self.status!)
                    }else{
                        service.validatePaymentFunc(vc: self,typeId:2, enquiryId: order.enquiryId, status: self.status!)
                    }
                }else if let enquiry = self.enquiryObject {
                    service.validatePaymentFunc(vc: self,typeId:1, enquiryId: enquiry.enquiryId, status: self.status!)
                }
            }
        default:
            print("do nothing")
        }
    }
}
