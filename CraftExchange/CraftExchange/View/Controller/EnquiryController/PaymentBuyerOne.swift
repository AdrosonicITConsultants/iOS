//
//  PaymentBuyerOneController.swift
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

class PaymentBuyerOneController: FormViewController{
    var enquiryObject: Enquiry?
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var percent = false
    var value = 30
    var PI: GetPI?
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
                if enquiryObject?.enquiryStageId ?? 0 < 2{
                    $0.cell.statusLbl.textColor = .black
                    $0.cell.statusDotView.backgroundColor = .black
                }else if enquiryObject?.enquiryStageId ?? 0 < 3{
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
            <<< PercentPaymentRow(){
                $0.tag = "TransactionBuyer"
                $0.cell.height = { 425.0 }
                $0.cell.thirtyBtn.tag = 100
                $0.cell.fiftyPercent.tag = 100
                $0.cell.tag = 100
                $0.cell.delegate = self
                $0.cell.TransactionBtn.setTitle("proceed with 30 percent ", for: .normal)
                $0.cell.ActualAmount.text = "₹ \(Double(self.enquiryObject!.totalAmount) * 0.3)"
                $0.cell.thirtyBtn.layer.borderWidth = 2.0
                $0.cell.thirtyBtn.layer.borderColor = UIColor.green.cgColor
                $0.cell.ActualAmount.layer.borderColor = UIColor.blue.cgColor
                $0.cell.ActualAmount.layer.borderWidth = 2.0
               
            }.cellUpdate({ (cell, row) in
                if self.value == 30 {
                     cell.TransactionBtn.setTitle("proceed with 30 percent ", for: .normal)
                    cell.ActualAmount.text = "₹ \(Double(self.enquiryObject!.totalAmount) * 0.30)"
                }
                else if self.value == 50 {
                     cell.TransactionBtn.setTitle("proceed with 50 percent ", for: .normal)
                    cell.ActualAmount.text = "₹ \(Double(self.enquiryObject!.totalAmount) * 0.50)"
                }
                else{
                    cell.TransactionBtn.setTitle("proceed with 30 percent ", for: .normal)
                    cell.ActualAmount.text = "₹ \(Double(self.enquiryObject!.totalAmount) * 0.30)"
                }
            })
    }
}
extension PaymentBuyerOneController: BTransactionButtonProtocol {
    func TransactionBtnSelected(tag: Int) {
         switch tag{
                case 100:
                let client = try? SafeClient(wrapping: CraftExchangeClient())
                let vc1 = EnquiryDetailsService(client: client!).createPaymentScene(enquiryId: self.enquiryObject!.enquiryId) as! PaymentUploadController
                vc1.enquiryObject = self.enquiryObject
                vc1.viewModel.totalAmount.value = "\(enquiryObject!.totalAmount)"
                vc1.viewModel.percentage.value = "\(self.value)"
                vc1.viewModel.paidAmount.value = "\(self.enquiryObject!.totalAmount * self.value / 100 )"
                vc1.viewModel.pid.value = "\(self.PI!.id)"
                vc1.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc1, animated: true)

                default:
                    print("Transaction Not working")
                }
    }
    
    func ThirtyBtnSelected(tag: Int) {
        self.value = 30
       
                     let row = self.form.rowBy(tag: "TransactionBuyer")
                     row?.updateCell()
        row?.reload()
        
    }
    
    func FiftyBtnSelected(tag: Int) {
        self.value = 50
              
                      let row = self.form.rowBy(tag: "TransactionBuyer")
                      row?.updateCell()
        row?.reload()
              
                
    }
    
    
}
