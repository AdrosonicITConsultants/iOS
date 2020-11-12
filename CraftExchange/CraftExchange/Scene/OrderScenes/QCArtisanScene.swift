//
//  QCArtisanScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit
import Eureka

extension QCService {
    func createQCArtisanScene(forOrder: Order) -> UIViewController {
        
        let vc = QCArtisanController.init(style: .plain)
        vc.orderObject = forOrder
        vc.title = forOrder.orderCode ?? ""
        
        vc.initialise = {
            self.fetchQCQuestionsData(vc: vc)
            self.fetchQCStagesData(vc: vc)
        }
        
        vc.viewWillAppear = {
            self.fetchQCForArtisan(enquiryId: forOrder.enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                do {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let dictionary = json["data"] as? [String: Any] {
                            vc.orderQCStageId = dictionary["stageId"] as? Int ?? 0
                            vc.orderQCIsSend = dictionary["isSend"] as? Int ?? 0
                            if let array = dictionary["artisanQcResponses"] as? [[[String: Any]]] {
                                try array .forEach { (obj) in
                                    try obj .forEach { (dict) in
                                        let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
                                        let question = try JSONDecoder().decode(QualityCheck.self, from: data)
                                        question.saveOrUpdate()
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                            vc.reloadData()
                                        }
                                    }
                                }
                                if array.count == 0 {
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                                        vc.reloadData()
                                    }
                                }
                            }else {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                                    vc.reloadData()
                                }
                            }
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
            }
        }
        
        vc.saveQualityCheck = { (stageID) in
            vc.showLoading()
            let qaArray = createQAArray(stageID: stageID)
            print("qcArr: \(qaArray)")
            let qualityObj = qualityCheck.init(stageId: stageID, enquiryId: forOrder.enquiryId, saveOrSend: 0, questionAnswers: qaArray)
            let request = OfflineOrderRequest.init(type: .sendOrSaveQCRequest, orderId: forOrder.enquiryId, changeRequestStatus: nil, changeRequestJson: qualityObj.toJSON(), submitRatingJson: nil)
            OfflineRequestManager.defaultManager.queueRequest(request)
        }
        
        vc.sendQualityCheck = { (stageID) in
            vc.showLoading()
            let qaArray = createQAArray(stageID: stageID)
            print("qcArr: \(qaArray)")
            let qualityObj = qualityCheck.init(stageId: stageID, enquiryId: forOrder.enquiryId, saveOrSend: 1, questionAnswers: qaArray)
            let request = OfflineOrderRequest.init(type: .sendOrSaveQCRequest, orderId: forOrder.enquiryId, changeRequestStatus: nil, changeRequestJson: qualityObj.toJSON(), submitRatingJson: nil)
            OfflineRequestManager.defaultManager.queueRequest(request)
        }
        
        func getQuestionID(answerRow: BaseRow) -> Int {
            if let strs = answerRow.tag?.components(separatedBy: "-").compactMap({ (str) -> String? in
                return str.replacingOccurrences(of: "-", with: "")
            }) {
                let questionId = strs[1]
                return Int(questionId) ?? 0
            }
            return 0
        }
        
        func createQAArray(stageID: Int) -> [[String:Any]] {
            var qaArray: [[String:Any]] = []
            vc.form.allRows .forEach { (row) in
                if row.tag?.starts(with: "\(stageID)-") ?? false {
                    if let answerRow = row as? RoundedTextFieldRow {
                        let questionId = getQuestionID(answerRow: answerRow)
                        qaArray.append(["questionId":Int(questionId) , "answer":"\(answerRow.cell.valueTextField.text ?? "")"])
                    }else if let answerRow = row as? ToggleOptionRow {
                        if answerRow.cell.titleLbl.textColor == UIColor().menuSelectorBlue() {
                            let questionId = getQuestionID(answerRow: answerRow)
                            var oldAnswer = ""
                            var index = -1
                            qaArray .forEach { (obj) in
                                if obj["questionId"] as? Int == questionId {
                                    oldAnswer = obj["answer"] as? String ?? ""
                                    index = qaArray.firstIndex(where: { (comparisonObj) -> Bool in
                                        comparisonObj["questionId"] as? Int == obj["questionId"] as? Int
                                    }) ?? -1
                                }
                            }
                            if oldAnswer == "" {
                                qaArray.append(["questionId":Int(questionId) , "answer":"\(answerRow.cell.titleLbl.text ?? "")"])
                            }else {
                                qaArray.remove(at: index)
                                qaArray.append(["questionId":Int(questionId) , "answer":"\(oldAnswer),\(answerRow.cell.titleLbl.text ?? "")"])
                            }
                        }
                    }else if let answerRow = row as? ActionSheetRow<String> {
                        let questionId = getQuestionID(answerRow: answerRow)
                        qaArray.append(["questionId":Int(questionId) , "answer":"\(answerRow.value ?? "")"])
                    }
                }
            }
            return qaArray
        }

        return vc
    }
    
    func fetchQCQuestionsData(vc: UIViewController) {
        self.fetchQCQuestions().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[[String: Any]]] {
                        
                        try array .forEach { (obj) in
                            try obj .forEach { (dict) in
                                let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
                                let question = try JSONDecoder().decode(QCQuestions.self, from: data)
                                question.saveOrUpdate()
                            }
                        }
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchQCStagesData(vc: UIViewController) {
        self.fetchQCStages().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([QCStages].self, from: data) .forEach({ (stage) in
                            stage.saveOrUpdate()
                        })
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
}
