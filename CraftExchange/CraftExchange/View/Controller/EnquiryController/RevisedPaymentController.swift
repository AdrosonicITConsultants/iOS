//
//  RevisedPaymentController.swift
//  CraftExchange
//
//  Created by Kalyan on 14/12/20.
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

class RevisedPaymentController: FormViewController{
    var enquiryObject: Enquiry?
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var Payment: RevisedAdvancedPayment?
    var revisedAdvancePaymentId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        form
            +++ Section()
            
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 200.0 }
                $0.cell.selectionStyle = .none
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                
                $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "\(Payment?.totalAmount ?? 0)" : "NA"
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let date = orderObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
                }
                $0.loadRowImage(orderObject: orderObject, enquiryObject: enquiryObject, vc: self)
            }
            <<< PendingPaymentRow(){
                $0.cell.height = { 350.0 }
                $0.cell.tag = 100
                $0.cell.advanceAmountPaid.text = "Advance amount paid as \(self.Payment?.percentage ?? 0)% of previous order amount: ₹ \(self.Payment?.paidAmount ?? 0)"
                $0.cell.pendingPaymentValue.setTitle("₹ \(self.Payment?.pendingAmount ?? 0)", for: .normal)
                $0.cell.delegate = self
            }.cellUpdate({ (cell, row) in
                cell.advanceAmountPaid.text = "Advance amount paid as \(self.Payment?.percentage ?? 0)% of previous order amount: ₹ \(self.Payment?.paidAmount ?? 0)"
                cell.pendingPaymentValue.setTitle("₹ \(self.Payment?.pendingAmount ?? 0)", for: .normal)
            })
    }
}
extension RevisedPaymentController: PendingPaymentProtocol {
    
    func pendingPaymentButtonSelected(tag: Int) {
        
        if self.Payment != nil {
           
                if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
                let vc1 = EnquiryDetailsService(client: client).createRevisedPaymentScene(enquiryId: self.orderObject?.enquiryId ?? 0) as! RevisedPaymentUploadController
                vc1.enquiryObject = self.enquiryObject
                vc1.orderObject = self.orderObject
                vc1.revisedPayment = self.Payment
                vc1.revisedAdvancePaymentId = self.revisedAdvancePaymentId
                vc1.viewModel.totalAmount.value = "\(enquiryObject?.totalAmount ?? orderObject?.totalAmount ?? 0)"
                vc1.viewModel.pid.value = "\(self.Payment?.piId ?? 0)"
                vc1.viewModel.percentage.value = "\(self.Payment?.percentage ?? 0)"
                vc1.viewModel.paidAmount.value = "\(self.Payment?.pendingAmount ?? 0 )"
                vc1.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc1, animated: true)
            }
        }
        
    }
    
    
}

