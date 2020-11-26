//
//  QCBuyerScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/11/20.
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
    func createQCBuyerScene(forOrder: AdminOrder) -> UIViewController {
        
        let vc = QCBuyerController.init(style: .plain)
        vc.orderObject = forOrder
        vc.title = forOrder.code ?? ""
        
        vc.initialise = {
            self.fetchQCQuestionsData(vc: vc)
            self.fetchQCStagesData(vc: vc)
        }
        
        vc.viewWillAppear = {
            self.fetchQCForBuyer(enquiryId: forOrder.entityID).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                do {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let arr = json["data"] as? [[String: Any]] {
                            DispatchQueue.main.async {
                                try? arr .forEach { (dict) in
                                    let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
                                    let question = try JSONDecoder().decode(QualityCheck.self, from: data)
                                    question.saveOrUpdate()
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                        vc.orderQCStageId = question.stageId
                                        vc.reloadData()
                                    }
                                }
                                if arr.count == 0 {
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                                        vc.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
            }
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
