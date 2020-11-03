//
//  ConfirmOrderReceivedController.swift
//  CraftExchange
//
//  Created by Kalyan on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
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

class ConfirmOrderReceivedViewModel {
    
    var orderDeliveryDate = Observable<String?>(nil)
}

class ConfirmOrderReceivedController: FormViewController{
    
    var enquiryObject: Enquiry?
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var isClosed = false
    var editEnabled = true
    lazy var viewModel = ConfirmOrderReceivedViewModel()
    
    //    let parentVC = self.parent as? PaymentUploadController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        
        form
            +++ Section()
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                
                if orderObject?.enquiryStageId == 9{
                    $0.cell.statusLbl.text = ""
                    // $0.cell.height = { 160.0 }
                    
                }
                $0.cell.statusLbl.text = "\(EnquiryStages.getStageType(searchId: self.orderObject?.enquiryStageId ?? 0)?.stageDescription ?? "-")"
                $0.cell.statusLbl.textColor = UIColor().CEGreen()
                $0.cell.statusDotView.backgroundColor = UIColor().CEGreen()
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if enquiryObject?.productType ?? orderObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = enquiryObject?.brandName ?? orderObject?.brandName
                }
                //print(tobePaidAmount)
                //                "
                
                //   $0.cell.amountLbl.text.height = { 0.0 }
                $0.cell.amountLbl.isHidden = true
                //   $0.cell.dateLbl.text.height = { 0.0 }
                $0.cell.dateLbl.isHidden = true
                
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
            
            <<< CompleteOrderIconRow(){
                $0.cell.height = { 150.0 }
            }
            <<< DateRow(){
                $0.title = "Date of Receiving"
                $0.cell.height = { 60.0 }
                $0.maximumDate = Date()
                if orderObject?.enquiryStageId == 10{
                    $0.hidden = false
                }else{
                    $0.hidden = true
                }
                $0.value = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.string(from: $0.value!)
                self.viewModel.orderDeliveryDate.value = date
                
            }.onChange({ (row) in
                    if let value = row.value {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.string(from: value)
                        self.viewModel.orderDeliveryDate.value = date
                        
                    }
                }).cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
                })
            
            <<< LabelRow(){
            $0.cell.height = { 20.0 }
                $0.title = ""
            }
            
            <<< LabelRow(){
                            $0.cell.height = { 80.0 }
                           
                            $0.title = "Please check the order before marking order complete. Once marked the order will be considered as completed and no concern can be raised against it."
                            $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .darkGray
                            cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                            cell.textLabel?.textAlignment = .center
                        })
            
            <<< LabelRow(){
            $0.cell.height = { 60.0 }
                $0.title = ""
            }
        
        <<< SingleButtonRow() {
                $0.tag = "Confirm Delivery"
                $0.cell.singleButton.backgroundColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                $0.cell.singleButton.setTitleColor(.white, for: .normal)
                $0.cell.singleButton.setTitle("Complete and Review", for: .normal)
                $0.cell.height = { 50.0 }
                $0.cell.delegate = self as SingleButtonActionProtocol
                $0.cell.tag = 100
        }
        
    }
    
    
}

extension ConfirmOrderReceivedController: SingleButtonActionProtocol, RatingInitaitionViewProtocol {
    
    func RevewAndRatingBtnSelected() {
        print("rating selected")
        
    }
    
    func skipBtnSelected() {
        self.view.hideRatingInitaitionView()
        self.popBack(toControllerType: OrderListController.self)
    }
    
    func singleButtonSelected(tag: Int) {
        switch tag {
        case 100:
           let client = try! SafeClient(wrapping: CraftExchangeClient())
           let service = EnquiryDetailsService.init(client: client)
           
           if orderObject?.enquiryId != nil && self.viewModel.orderDeliveryDate.value != nil {
            self.showLoading()
            service.markOrderAsReceivedfunc(orderId: orderObject!.enquiryId, orderRecieveDate: self.viewModel.orderDeliveryDate.value!, vc: self)
           }
        default:
            print("do nothing")
        }
    }
    
    
}

