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
                $0.cell.height = { 200.0 }
                $0.cell.selectionStyle = .none

                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                
                //   $0.cell.amountLbl.text.height = { 0.0 }
                $0.cell.amountLbl.isHidden = true
                //   $0.cell.dateLbl.text.height = { 0.0 }
                $0.cell.dateLbl.isHidden = true
                
                $0.loadRowImage(orderObject: orderObject, enquiryObject: enquiryObject)
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
            <<< LabelRow(){
                $0.cell.height = {50.0}
                
                $0.title = ""
        }
        
    }
    
    
}

extension ConfirmOrderReceivedController: SingleButtonActionProtocol, RatingInitaitionViewProtocol {
    
    func RevewAndRatingBtnSelected() {
        if self.orderObject != nil {
            var orderList = false
            var orderListVC: OrderListController?
            self.navigationController?.viewControllers .forEach({ (controller) in
                if controller.isKind(of: OrderListController.self) {
                    orderList = true
                    orderListVC = controller as? OrderListController
                }
            })
            if orderList {
                if let orderVC = orderListVC {
                    self.navigationController?.popToViewController(orderVC, animated: true)
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeClient())
                        let vc = OrderDetailsService(client: client).createProvideRatingScene(forOrder: self.orderObject, enquiryId: self.orderObject?.enquiryId ?? 0) as! ProvideRatingController
                        vc.orderObject = self.orderObject
                        let nav = self.getNavBar()
                        nav?.pushViewController(vc, animated: true)
                    } catch let error {
                        print("Unable to load view:\n\(error.localizedDescription)")
                    }
                }
            }else {
                self.navigationController?.popToRootViewController(animated: true)
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let listvc = OrderListService(client: client).createScene()
                    let nav = self.getNavBar()
                    nav?.pushViewController(listvc, animated: true)
                    let vc = OrderDetailsService(client: client).createProvideRatingScene(forOrder: self.orderObject, enquiryId: self.orderObject?.enquiryId ?? 0) as! ProvideRatingController
                    vc.orderObject = self.orderObject
                    nav?.pushViewController(vc, animated: true)
                } catch let error {
                    print("Unable to load view:\n\(error.localizedDescription)")
                }
            }
        }
        print("rating selected")
    }
    
    func skipBtnSelected() {
        self.view.hideRatingInitaitionView()
        var orderList = false
        var orderListVC: OrderListController?
        self.navigationController?.viewControllers .forEach({ (controller) in
            if controller.isKind(of: OrderListController.self) {
                orderList = true
                orderListVC = controller as? OrderListController
            }
        })
        if orderList {
            if let orderVC = orderListVC {
                self.navigationController?.popToViewController(orderVC, animated: true)
            }
        }else {
            self.navigationController?.popToRootViewController(animated: true)
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = OrderListService(client: client).createScene()
                let nav = self.getNavBar()
                nav?.pushViewController(vc, animated: true)
            } catch let error {
                print("Unable to load view:\n\(error.localizedDescription)")
            }
        }
    }
    
    func singleButtonSelected(tag: Int) {
        switch tag {
        case 100:
            if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
                let service = EnquiryDetailsService.init(client: client)
                
                if orderObject?.enquiryId != nil && self.viewModel.orderDeliveryDate.value != nil {
                    self.showLoading()
                    service.markOrderAsReceivedfunc(orderId: orderObject!.enquiryId, orderRecieveDate: self.viewModel.orderDeliveryDate.value!, vc: self)
                }
            }
        default:
            print("do nothing")
        }
    }
    
    
}

