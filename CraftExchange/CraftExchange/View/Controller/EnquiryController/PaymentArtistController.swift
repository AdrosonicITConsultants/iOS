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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let client = try! SafeClient(wrapping: CraftExchangeClient())
        let service = EnquiryDetailsService.init(client: client)
        service.advancePaymentStatus(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0)
        if orderObject?.enquiryStageId == 8 {
            service.downloadAndViewReceipt(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0, typeId: 2)
        }else{
            service.downloadAndViewReceipt(vc: self, enquiryId: self.enquiryObject?.enquiryId ?? self.orderObject?.entityID ?? 0, typeId: 1)
        }
        
        
        form
            +++ Section()
            
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if enquiryObject?.productType == "Custom Product" || orderObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = enquiryObject?.brandName ?? orderObject?.brandName
                }
                $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "\(enquiryObject?.totalAmount ?? 0)" : "NA"
                if orderObject != nil {
                    $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "\(orderObject?.totalAmount ?? 0)" : "NA"
                }
                if orderObject?.enquiryStageId == 8{
                    $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "Paid amount: " + "\(finalPaymnetDetails?.payableAmount ?? 0)" : "NA"
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
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
                }
                if let tag = enquiryObject?.productImages?.components(separatedBy: ",").first ?? orderObject?.productImages?.components(separatedBy: ",").first, let prodId = enquiryObject?.productId ?? orderObject?.productId {
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
                $0.title = "Payment Receipt: "
            }
        <<< ArtistReceitImgRow(){
            $0.cell.height = { 325.0 }
//               $0.cell.delegate = self
               $0.tag = "PaymentArtist-1"
               $0.cell.tag = 4
        }
            
        <<< ApprovePaymentRow() {
            $0.cell.height = { 150.0}
            $0.cell.ApproveBTn.tag = 5
            $0.tag = "PaymentArtist-2"
            $0.cell.tag = 5
            if orderObject?.enquiryStageId == 8{
                $0.cell.ApproveBTn.setTitle("Approve Final Payment by Buyer", for: .normal)
            }
            $0.cell.delegate = self
            if enquiryObject?.enquiryStageId ?? orderObject?.enquiryStageId ?? 0 >= 4{
                $0.hidden = true
            }
            if orderObject?.enquiryStageId == 8{
                 $0.hidden = false
            }
//            if orderObject?.isBlue == true {
//                 $0.hidden = false
//            }else{
//                $0.hidden = true
//            }
        }
        
}
}
extension PaymentArtistController: ApproveButtonProtocol {
    func RejectBtnSelected(tag: Int) {
       switch tag{
        case 5:
            self.status = 2
            self.showLoading()
            let client = try! SafeClient(wrapping: CraftExchangeClient())
            let service = EnquiryDetailsService.init(client: client)
            if let order = self.orderObject {
                if self.orderObject?.enquiryStageId == 8{
                   service.validatePaymentFunc(vc: self,typeId: 2, enquiryId: order.enquiryId, status: self.status!)
                }else{
                    service.validatePaymentFunc(vc: self,typeId: 1, enquiryId: order.enquiryId, status: self.status!)
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
            let client = try! SafeClient(wrapping: CraftExchangeClient())
            let service = EnquiryDetailsService.init(client: client)
            if let order = self.orderObject {
                if self.orderObject?.enquiryStageId == 8{
                    service.validatePaymentFunc(vc: self,typeId:2, enquiryId: order.enquiryId, status: self.status!)
                }else{
                    service.validatePaymentFunc(vc: self,typeId:1, enquiryId: order.enquiryId, status: self.status!)
                }
                
            }
        default:
             print("do nothing")
        }
    }
}
