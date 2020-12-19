//
//  QCArtisanController.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
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

class QCArtisanController: FormViewController {
    var orderObject: Order?
    var initialise: (() -> ())?
    var viewWillAppear: (() -> ())?
    var saveQualityCheck: ((_ stageID: Int) -> ())?
    var sendQualityCheck: ((_ stageID: Int) -> ())?
    var stagesArray: Results<QCStages>?
    var questionsArray: Results<QCQuestions>?
    var artisanQCArray: Results<QualityCheck>?
    let realm = try? Realm()
    var orderQCStageId: Int = 0
    var orderQCIsSend: Int = 0
    var showSection: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.initialise?()
        
        let rightButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        stagesArray = realm?.objects(QCStages.self).sorted(byKeyPath: "entityID", ascending: true)
        questionsArray = realm?.objects(QCQuestions.self)
        if let userID = User.loggedIn()?.entityID {
            artisanQCArray = realm?.objects(QualityCheck.self).filter("%K = %@","artisanId",userID).filter("%K == %@","enquiryId",orderObject?.entityID ?? 0)
        }
        
        let stageSection = Section() {
            $0.hidden = "$stageTypes == false"
            $0.tag = "QCSection"
        }
        
        let stageView = LabelRow("stageTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Quality Check".localized
        }
        
        form
            +++ Section()
            <<< EnquiryDetailsRow() { (row) in
                row.configureRow(orderObject: orderObject, enquiryObject: nil)
                row.loadRowImage(orderObject: orderObject, enquiryObject: nil, vc: self)
            }.cellUpdate({ (cell, row) in
                row.cellUpdate(orderObject: self.orderObject, enquiryObject: nil)
            })
            <<< stageView
            +++ stageSection
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "QCRevised"), object: nil, queue: .main) { (notif) in
            let qcSec = self.form.sectionBy(tag: "QCSection")
            qcSec?.removeAll()
            self.showSection = nil
            self.viewWillAppear?()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppear?()
    }
    
    func reloadData() {
        self.hideLoading()
        guard let stageSection = self.form.sectionBy(tag: "QCSection") else {
            return }
        if orderQCStageId == 0 {
            showSection = "0"
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
                        cell.titleLbl.textColor = UIColor().CEMustard()
                        cell.backgroundColor = .white
                        cell.titleLbl.font = .systemFont(ofSize: 15, weight: .light)
                        if self.orderQCStageId != 0 {
                            if self.orderQCStageId == 7 {
                                cell.row.hidden = false
                            }else {
                                if self.orderQCIsSend == 1 {
                                    if Int(cell.row.tag ?? "0") ?? 0 <= self.orderQCStageId+1 {
                                        cell.row.hidden = false
                                    }else {
                                        cell.row.hidden = true
                                    }
                                }else {
                                    if Int(cell.row.tag ?? "0") ?? 0 <= self.orderQCStageId {
                                        cell.row.hidden = false
                                    }else {
                                        cell.row.hidden = true
                                    }
                                }
                            }
                        }else {
                            if cell.row.tag == "1" {
                                cell.row.hidden = false
                            }else {
                                cell.row.hidden = true
                            }
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
                                        if Int(cell.row.tag ?? "0") ?? 0 <= self.orderQCStageId+1 {
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
                    var showSave = false
                    if let qcArray = questionsArray?.filter("%K == %@","stageId",stage.entityID).sorted(byKeyPath: "entityID"), qcArray.count > 0 {
                        qcArray .forEach { (question) in
                            if let getQC = self.artisanQCArray?.filter("%K == %@ AND %K == %@","stageId",stage.entityID,"questionId",question.questionNo).sorted(byKeyPath: "modifiedOn", ascending: false).first {
                                //                                let index = (Int(self.showSection ?? "0") ?? 0)+1
                                if (getQC.stageId == self.orderQCStageId && self.orderQCIsSend == 1) || getQC.stageId < self.orderQCStageId {
                                    print("is Not Editable")
                                    showSave = false
                                    stageSection <<< RoundedTextFieldRow() {
                                        $0.cell.height = { 80.0 }
                                        $0.tag = "\(stage.entityID)-\(question.questionNo)-ans"
                                        $0.hidden = true
                                        $0.cell.titleLabel.text = question.question ?? ""
                                        $0.cell.titleLabel.textColor = .black
                                        $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                                        $0.cell.compulsoryIcon.isHidden = true
                                        $0.cell.backgroundColor = .white
                                        $0.cell.valueTextField.text = getQC.answer ?? "NO RESPONSE".localized
                                        $0.cell.valueTextField.textColor = .darkGray
                                    }.cellUpdate({ (cell, row) in
                                        cell.isUserInteractionEnabled = false
                                        cell.valueTextField.isUserInteractionEnabled = false
                                        cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                                        cell.valueTextField.leftPadding = 0
                                    })
                                }else {
                                    print("is Editable")
                                    showSave = true
                                    let arr = self.getAnswerCellWithTag(question: question)
                                    arr .forEach { (row) in
                                        stageSection <<< row
                                    }
                                }
                            }else {
                                print("is Editable")
                                showSave = true
                                let arr = self.getAnswerCellWithTag(question: question)
                                arr .forEach { (row) in
                                    stageSection <<< row
                                }
                            }
                        }
                    }
                    if showSave {
                        if stage.entityID == 7 {
                            stageSection <<< LabelRow() {
                                $0.cell.height = { 120.0 }
                                $0.cell.tag = stage.entityID
                                $0.tag = "\(stage.entityID)-Disclaimer"
                                $0.title = "Declaration by AE- I, hereby certify from my end that all the processes have been Monitored & Supervised under my guidence and any issue in Quality Certified by me in person or my staff in charge is liable to be discussed with me directly on mail. Once the goods received at your doorsteps, we will not be liable for quality issue if informed after 72 hrs of receipts.".localized
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .black
                                cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                                cell.textLabel?.numberOfLines = 10
                                if cell.row.tag == "\(self.showSection ?? "0")-Disclaimer" {
                                    cell.row.hidden = false
                                }else {
                                    cell.row.hidden = true
                                }
                            })
                        }
                        stageSection <<< SaveAndSendQCRow() {
                            $0.cell.height = { 60.0 }
                            $0.cell.btnSave.tag = stage.entityID
                            $0.cell.btnSend.tag = stage.entityID
                            $0.cell.delegate = self
                            $0.cell.tag = stage.entityID
                            $0.tag = "\(stage.entityID)-SaveSend"
                        }.cellUpdate({ (cell, row) in
                            if cell.row.tag == "\(self.showSection ?? "0")-SaveSend" {
                                cell.row.hidden = false
                            }else {
                                cell.row.hidden = true
                            }
                        })
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
    
    func getAnswerCellWithTag(question: QCQuestions) -> [BaseRow] {
        var row = LabelRow()
        var answer = ""
        var selectedOptions: [String] = []
        if let getQC = self.artisanQCArray?.filter("%K == %@ AND %K == %@","stageId",question.stageId,"questionId",question.questionNo).sorted(byKeyPath: "modifiedOn", ascending: false).first {
            answer = getQC.answer ?? ""
            if question.answerType == "1" {
                selectedOptions = getQC.answer?.components(separatedBy: ",").compactMap({ (opt) -> String? in
                    return opt.replacingOccurrences(of: ",", with: "")
                }) ?? []
            }
        }
        switch question.answerType {
        case "0":
            print("textfield")
            let textFieldRow = RoundedTextFieldRow() {
                $0.cell.height = { 80.0 }
                $0.tag = "\(question.stageId)-\(question.questionNo)-ans"
                $0.hidden = true
                $0.cell.titleLabel.text = question.question ?? ""
                $0.cell.titleLabel.textColor = .black
                $0.cell.titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.placeholder = "Your comments...".localized
                $0.cell.valueTextField.textColor = .darkGray
                $0.cell.valueTextField.text = answer
                if question.stageId == 7 && question.questionNo == 12 {
                    $0.cell.valueTextField.maxLength = 100
                }else {
                    $0.cell.valueTextField.maxLength = 25
                }
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = true
                cell.valueTextField.isUserInteractionEnabled = true
                cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                cell.valueTextField.leftPadding = 0
                let currentSection = (Int(self.showSection ?? "0") ?? 0)
                if cell.row.tag == "\(currentSection)-\(question.entityID)-ans" {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            return [textFieldRow]
        case "1":
            print("multiple choice")
            var optionRows: [BaseRow] = []
            var options: [String] = []
            if let opts = question.optionValue?.components(separatedBy: ",").compactMap({ (str) -> String? in
                return str.replacingOccurrences(of: ",", with: "")
            }) {
                row = LabelRow() {
                    $0.cell.height = { 30.0 }
                    $0.tag = "\(question.stageId)-\(question.questionNo)-Lbl"
                }.cellUpdate({ (cell, row) in
                    cell.row.title = question.question ?? ""
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    if cell.row.tag == "\(self.showSection ?? "0")-\(question.entityID)-Lbl" {
                        cell.row.hidden = false
                    }else {
                        cell.row.hidden = true
                    }
                })
                optionRows.append(row)
                options = opts
                var i = 0
                options.forEach({ (opt) in
                    let optionRow = ToggleOptionRow() {
                        $0.cell.height = { 45.0 }
                        $0.cell.titleLbl.text = opt
                        $0.cell.titleLbl.textColor = .lightGray
                        $0.cell.toggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                        $0.cell.washCare = false
                        $0.cell.toggleDelegate = self
                        $0.hidden = true
                        $0.tag = "\(question.stageId)-\(question.questionNo)-\(i)-ans"
                        if selectedOptions.contains(opt){
                            $0.cell.titleLbl.textColor = UIColor().menuSelectorBlue()
                            $0.cell.toggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                        }else {
                            $0.cell.titleLbl.textColor = .lightGray
                            $0.cell.toggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                        }
                    }.onCellSelection({ (cell, row) in
                        cell.toggleButton.sendActions(for: .touchUpInside)
                        cell.contentView.backgroundColor = .white
                    }).cellUpdate { (cell, row) in
                        let currentSection = (Int(self.showSection ?? "0") ?? 0)
                        if cell.row.tag == "\(currentSection)-\(question.entityID)-ans" {
                            cell.row.hidden = false
                        }else {
                            cell.row.hidden = true
                        }
                    }
                    i = i + 1
                    optionRows.append(optionRow)
                })
                return optionRows
            }
        case "2","3":
            print("dropdown choice")
            let actionSheetRow = ActionSheetRow<String>() {
                $0.title = question.question ?? ""
                $0.tag = "\(question.stageId)-\(question.questionNo)-ans"
                $0.cell.height = { 80.0 }
                if let options = question.optionValue?.components(separatedBy: ";").compactMap({ (str) -> String? in
                    return str.replacingOccurrences(of: ";", with: "")
                }) {
                    $0.options = options
                }
                $0.value = answer
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                let currentSection = (Int(self.showSection ?? "0") ?? 0)
                if cell.row.tag == "\(currentSection)-\(question.entityID)-ans" {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            }
            return [actionSheetRow]
        default:
            print("do nothing")
        }
        return [row]
    }
    
    @objc func goToChat() {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let service = ChatListService.init(client: client)
            if let enquiryId = orderObject?.enquiryId {
                service.initiateConversation(vc: self, enquiryId: enquiryId)
            }
        }catch {
            print(error.localizedDescription)
        }
    }
}

extension QCArtisanController: ToggleButtonProtocol, SaveAndSendBtnProtocol {
    
    func toggleButtonSelected(tag: Int, forWashCare: Bool) {
        
    }
    
    func saveQC(tag: Int) {
        self.saveQualityCheck?(tag)
    }
    
    func sendQC(tag: Int) {
        self.sendQualityCheck?(tag)
    }
}
