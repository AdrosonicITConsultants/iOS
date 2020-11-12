//
//  ViewRatingController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 30/10/20.
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
import Cosmos

class ViewRatingViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
}
class ViewRatingController: FormViewController {
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    lazy var viewModel = ViewRatingViewModel()
    let realm = try? Realm()
    var allBuyerRatingQuestions : Results<RatingQuestionsBuyer>?
    var allBuyerRatingResponse: Results<RatingResponseBuyer>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        allBuyerRatingQuestions = realm!.objects(RatingQuestionsBuyer.self).sorted(byKeyPath: "entityID")
        allBuyerRatingResponse = realm!.objects(RatingResponseBuyer.self).filter("%K == %@", "enquiryId", orderObject?.enquiryId ?? 0).sorted(byKeyPath: "entityID")
        
        form
            +++ Section()
            <<< ViewRatingRow() {
                $0.cell.height = { 200.0 }
                $0.tag = "ViewRating"
                $0.cell.RatingLabel.text = "0.0"
            }.cellUpdate({ (cell, row) in
                var ResponseArray:[Int] = []
                if self.allBuyerRatingResponse != nil{
                    for object in self.allBuyerRatingResponse! {
                        if object.responseComment == nil {
                            ResponseArray.append(object.response)
                            cell.RatingLabel.text = "\((Double(ResponseArray.reduce(0, +))/Double(ResponseArray.count)))"
                        }
                    }
                }
            })
            
            +++ Section(){ section in
                section.tag = "Buyer Response"
        }
        
        if allBuyerRatingQuestions != nil && allBuyerRatingResponse != nil {
            self.buyerResponseFunc()
        }
    }
    
    func reloadFormData() {
        
        if self.allBuyerRatingQuestions != nil && self.allBuyerRatingResponse != nil {
            
            let section = self.form.sectionBy(tag: "Buyer Response")
            if section?.isEmpty == true {
                self.buyerResponseFunc()
            }
            
        }
    }
    
    func buyerResponseFunc(){
        if let buyerResponseSection = self.form.sectionBy(tag: "Buyer Response") {
            if allBuyerRatingQuestions != nil && allBuyerRatingResponse != nil {
                let showBuyerRatingQuestions = allBuyerRatingQuestions!
                let showBuyerRatingResponse = allBuyerRatingResponse!
                
                buyerResponseSection <<< LabelRow(){
                    $0.cell.height = { 20.0 }
                    $0.title = ""
                }
                buyerResponseSection <<< LabelRow(){
                    $0.cell.height = { 15.0 }
                    $0.title = "Response".localized
                    
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    cell.textLabel?.font = .systemFont(ofSize: 19, weight: .regular)
                })
                for object1 in showBuyerRatingQuestions {
                    for object2 in showBuyerRatingResponse {
                        if object1.answerType == 2 && object1.entityID == object2.questionId {
                            
                            buyerResponseSection <<< TextAreaRow() {
                                $0.cell.height = {150.0}
                                $0.cell.textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                                $0.cell.textView.layer.borderWidth = 1
                                $0.value = object2.responseComment
                                $0.cell.isUserInteractionEnabled = false
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                                cell.textView?.font = .systemFont(ofSize: 13, weight: .regular)
                                cell.textView?.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                            })
                        }
                    }
                }
                for object1 in showBuyerRatingQuestions {
                    for object2 in showBuyerRatingResponse {
                        
                        if object1.answerType == 1 && object1.entityID == object2.questionId {
                            buyerResponseSection <<< LabelRow(){
                                $0.title = object1.question
                                $0.cellStyle = .default
                                $0.cell.textLabel?.numberOfLines = 2
                                $0.cell.textLabel?.textAlignment = .center
                                $0.cell.textLabel?.center = self.view.center
                            }
                            buyerResponseSection <<< RatingStarsRow() {
                                $0.cell.height = { 50.0 }
                                $0.cell.isUserInteractionEnabled = false
                                $0.cell.StarsView.rating = (Double(object2.response))/2.0
                                $0.cell.selectionStyle = .none
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadFormData()
        
    }
}

