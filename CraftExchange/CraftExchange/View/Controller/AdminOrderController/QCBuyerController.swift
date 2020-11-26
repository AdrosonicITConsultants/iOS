//
//  QCBuyerController.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/11/20.
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

class QCBuyerController: FormViewController {
    var orderObject: AdminOrder?
    var initialise: (() -> ())?
    var viewWillAppear: (() -> ())?
    var stagesArray: Results<QCStages>?
    var questionsArray: Results<QCQuestions>?
    var buyerQCArray: Results<QualityCheck>?
    let realm = try? Realm()
    var orderQCStageId: Int = 0
    var showSection: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.initialise?()
        
        let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem

        stagesArray = realm?.objects(QCStages.self).sorted(byKeyPath: "entityID", ascending: true)
        questionsArray = realm?.objects(QCQuestions.self)
        if let _ = User.loggedIn()?.entityID {
            buyerQCArray = realm?.objects(QualityCheck.self).filter("%K == %@","enquiryId",orderObject?.entityID ?? 0).sorted(byKeyPath: "stageId", ascending: false)
            self.orderQCStageId = buyerQCArray?.first?.stageId ?? 0
        }
        
        let stageSection = Section() {
            $0.hidden = "$stageTypes == false"
            $0.tag = "QCSection"
        }

        let stageView = LabelRow("stageTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Quality Check".localized
        }.cellUpdate { (cell, row) in
            cell.contentView.backgroundColor = .black
            cell.textLabel?.textColor = UIColor().CEMustard()
            cell.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        }
        
        form
        +++ Section()
            /*<<< EnquiryDetailsRow() { (row) in
                row.configureRow(orderObject: orderObject, enquiryObject: nil)
            }.cellUpdate({ (cell, row) in
                row.cellUpdate(orderObject: self.orderObject, enquiryObject: nil)
            })*/
        <<< stageView
        +++ stageSection
        
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
        guard let stageSection = self.form.sectionBy(tag: "QCSection") else {
            
            return }
        if orderQCStageId == 0 {
            showSection = "0"
        }
        if let _ = User.loggedIn()?.entityID {
            buyerQCArray = realm?.objects(QualityCheck.self).filter("%K == %@","enquiryId",orderObject?.entityID ?? 0).sorted(byKeyPath: "stageId", ascending: false)
            self.orderQCStageId = buyerQCArray?.first?.stageId ?? 0
        }
        
        if let qcRow = self.form.rowBy(tag: "QC-NA") {
            qcRow.hidden = self.buyerQCArray?.count == 0 ? false : true
            qcRow.evaluateHidden()
        }else {
            stageSection <<< LabelRow() {
                $0.cell.height = { 60.0 }
                $0.title = "Not Available"
                $0.tag = "QC-NA"
            }.cellUpdate({ (cell, row) in
                cell.contentView.backgroundColor = .black
                cell.textLabel?.textColor = .white
                cell.textLabel?.textAlignment = .center
                if self.buyerQCArray?.count == 0 {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
        }
        
        
        if let stageArray = stagesArray, stageArray.count > 0 {
            stageArray .forEach { (stage) in
                if self.form.rowBy(tag: "\(stage.entityID)") == nil {
                    stageSection <<< BuyerEnquirySectionViewRow() {
                        $0.cell.height = { 60.0 }
                        $0.cell.titleLbl.text = stage.stage ?? ""
                        $0.cell.valueLbl.text = ""
                        $0.tag = "\(stage.entityID)"
                    }.cellUpdate({ (cell, row) in
                        cell.contentView.backgroundColor = .black
                        cell.titleLbl.textColor = UIColor().CEMustard()
                        cell.backgroundColor = .black
                        cell.titleLbl.font = .systemFont(ofSize: 15, weight: .light)
                        if self.orderQCStageId != 0 {
                            if self.orderQCStageId == 7 {
                                cell.row.hidden = false
                            }else {
                                if Int(cell.row.tag ?? "0") ?? 0 <= self.orderQCStageId {
                                    cell.row.hidden = false
                                }else {
                                    cell.row.hidden = true
                                }
                            }
                        }else {
                           cell.row.hidden = true
                        }
                    }).onCellSelection({ (cell, row) in
                        if self.showSection != cell.row.tag {
                            self.showSection = cell.row.tag
                        }else {
                            self.showSection = "0"
                        }
                        self.form.allRows.forEach { (row) in
                            if row.tag?.starts(with: "\(self.showSection ?? "0")-") ?? false {
                                row.hidden = false
                            }else{
                                if !(row.tag?.contains("-") ?? true){
                                    if self.orderQCStageId == 7 {
                                        cell.row.hidden = false
                                    }else {
                                        if Int(cell.row.tag ?? "0") ?? 0 <= self.orderQCStageId {
                                            cell.row.hidden = false
                                        }else {
                                            cell.row.hidden = true
                                        }
                                    }
                                }else {
                                    row.hidden = true
                                }
                            }
                            row.evaluateHidden()
                        }
                        self.form.allSections.forEach { (section) in
                            section.reload()
                        }
                    })

                    if let qcArray = questionsArray?.filter("%K == %@","stageId",stage.entityID).sorted(byKeyPath: "entityID"), qcArray.count > 0 {
                        qcArray .forEach { (question) in
                            if let getQC = self.buyerQCArray?.filter("%K == %@ AND %K == %@","stageId",stage.entityID,"questionId",question.questionNo).sorted(byKeyPath: "modifiedOn", ascending: false).first {
                                stageSection <<< RoundedTextFieldRow() {
                                    $0.cell.height = { 80.0 }
                                    $0.tag = "\(stage.entityID)-\(question.questionNo)-ans"
                                    $0.hidden = true
                                    $0.cell.titleLabel.text = question.question ?? ""
                                    $0.cell.titleLabel.textColor = UIColor.init(named: "AdminGreenText")
                                    $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                                    $0.cell.compulsoryIcon.isHidden = true
                                    $0.cell.backgroundColor = .white
                                    $0.cell.valueTextField.text = getQC.answer?.isNotBlank ?? false ? getQC.answer ?? "NO RESPONSE" : "NO RESPONSE"
                                    $0.cell.valueTextField.textColor = .white
                                }.cellUpdate({ (cell, row) in
                                    cell.isUserInteractionEnabled = false
                                    cell.contentView.backgroundColor = .darkGray
                                    cell.valueTextField.isUserInteractionEnabled = false
                                    cell.valueTextField.layer.borderColor = UIColor.darkGray.cgColor
                                    cell.valueTextField.leftPadding = 0
                                    cell.valueTextField.textColor = .white
                                })
                            }
                        }
                    }
                }
            }
        }
        self.form.allSections.forEach { (section) in
            section.reload()
        }
        self.form.allRows.forEach { (row) in
            row.reload()
        }
    }
    
    @objc func goToChat() {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let service = ChatListService.init(client: client)
            if let enquiryId = orderObject?.entityID {
                service.initiateConversation(vc: self, enquiryId: enquiryId)
            }
        }catch {
            print(error.localizedDescription)
        }
    }
}


