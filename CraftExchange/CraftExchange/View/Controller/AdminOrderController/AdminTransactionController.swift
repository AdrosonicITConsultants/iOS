//
//  AdminTransactionController.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
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

class AdminTransactionController: FormViewController {
    var enquiry: Int = 0
    var initialise: (() -> ())?
    var viewWillAppear: (() -> ())?
    var listTransactions: [TransactionObject]?
    let realm = try? Realm()
    var code: String?
    var viewTransactionReceipt: ((_ transactionObj: TransactionObject, _ isOld: Int, _ isPI: Bool) -> ())?
    var downloadAdvReceipt: ((_ enquiryId: Int) -> ())?
    var downloadFinalReceipt: ((_ enquiryId: Int) -> ())?
    var downloadDeliveryReceipt: ((_ enquiryId: Int, _ imageName: String) -> ())?
    var checkTransactions: (() -> ())?
    var downloadPI: ((_ isPI: Bool,_ isOld: Bool) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.initialise?()
        checkTransactions?()
        
        let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        form
        +++ Section()
        <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Your Transactions".localized
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor.init(named: "EscalationBg")
            $0.cell.titleLbl.textColor = .white
                $0.cell.valueLbl.textColor = UIColor.init(named: "ArmyGreenText")
            }.onCellSelection({ (cell, row) in
                let section = self.form.sectionBy(tag: "list Transactions")
                if section?.isEmpty == true {
                    self.listTransactionsFunc()
                }else {
                    section?.removeAll()
                }
                section?.reload()
                
            }).cellUpdate({ (cell, row) in
                cell.titleLbl.font = .systemFont(ofSize: 18, weight: .bold)
            })
            +++ Section(){ section in
                section.tag = "list Transactions"
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "QCRevised"), object: nil, queue: .main) { (notif) in
            self.hideLoading()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppear?()
    }
    
    func reloadData() {
        
    }
    
    func listTransactionsFunc() {
        if let listMOQSection = self.form.sectionBy(tag: "list Transactions") {
            let showTransactions = listTransactions!
            showTransactions.forEach({ (obj) in
                listMOQSection <<< TransactionTitleRowView() {
                    $0.cell.height = { 60.0 }
                    $0.cell.configure(obj)
                }.onCellSelection({ (cell, row) in
                    let row = self.form.rowBy(tag: obj.id!)
                    if row?.isHidden == true {
                        row?.hidden = false
                    }else {
                        row?.hidden = true
                    }
                    row?.evaluateHidden()
                    listMOQSection.reload()
                })
                    
                <<< TransactionDetailRowView() {
                    $0.cell.height = { 60.0 }
                    $0.cell.configure(obj)
                    $0.cell.tag = obj.entityID
                    $0.cell.invoiceButton.tag = obj.entityID
                    $0.cell.delegate = self as TransactionListProtocol
                    $0.hidden = true
                    $0.tag = obj.id
                }
            })
        }
        self.form.sectionBy(tag: "list Transactions")?.reload()
    }
    
    @objc func goToChat() {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let service = ChatListService.init(client: client)
            service.initiateConversation(vc: self, enquiryId: enquiry)
        }catch {
            print(error.localizedDescription)
        }
    }
}

extension AdminTransactionController: TransactionListProtocol, TransactionReceiptViewProtocol, AcceptedPIViewProtocol {
    
    func backButtonSelected() {
        self.view.hideAcceptedPIView()
    }
    
    func downloadButtonSelected(isOld: Bool) {
        self.downloadPI?(true, isOld)
    }
    
    func TIdownloadButtonSelected() {
        self.downloadPI?(false, false)
    }
    
    func viewTransactionReceipt(tag: Int) {
        
        let showMOQ = listTransactions!
        showMOQ.forEach({ (obj) in
            print(obj)
            switch tag {
            case obj.entityID:
                print(obj)
                let invoiceStateArray = [1,2,3,4,5]
                let advancePaymentArray = [6,8,10]
                let taxInvoiceArray = [12,13]
                let finalPaymentarray = [14,16,18]
                let deliveryReciptArray = [20]
                if invoiceStateArray.contains(obj.accomplishedStatus) {
                    self.viewTransactionReceipt?(obj, 0, true)
                }else if advancePaymentArray.contains(obj.accomplishedStatus){
                    self.downloadAdvReceipt?(obj.enquiryId)
                }
                else if finalPaymentarray.contains(obj.accomplishedStatus){
                    self.downloadFinalReceipt?(obj.enquiryId)
                }else if taxInvoiceArray.contains(obj.accomplishedStatus) {
                    self.viewTransactionReceipt?(obj, 0, false)
                }
                else if deliveryReciptArray.contains(obj.accomplishedStatus) {
                    self.showLoading()
                    self.downloadDeliveryReceipt?(enquiry, "")
                }
            default:
                print("do nothing")
                
            }
        })
        
    }
    
    func cancelBtnSelected() {
        self.view.hideTransactionReceiptView()
    }
}

