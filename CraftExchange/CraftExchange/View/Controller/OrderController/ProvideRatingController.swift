//
//  ProvideRatingController.swift
//  CraftExchange
//
//  Created by Kalyan on 11/11/20.
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

class ProvideRatingViewModel {
    var buyerComment = Observable<String?>(nil)
    var artisanComment = Observable<String?>(nil)
    
}
class ProvideRatingController: FormViewController {
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    var sendRating: ((_ sendRatingarray:[[String: Any]]) -> ())?
    var isBuyerRatingDone: Int?
    var isArtisanRatingDone: Int?
    lazy var viewModel = ProvideRatingViewModel()
    let realm = try? Realm()
    var ratingDict: [Int: Int] = [:]
    var sendRatingObj: [[String: Any]] = []
    var allBuyerRatingQuestions : Results<RatingQuestionsBuyer>?
    var allArtisanRatingQuestions : Results<RatingQuestionsArtisan>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        allBuyerRatingQuestions = realm!.objects(RatingQuestionsBuyer.self).sorted(byKeyPath: "entityID")
        allArtisanRatingQuestions = realm!.objects(RatingQuestionsArtisan.self).sorted(byKeyPath: "entityID")
        
        form
            +++ Section(){ section in 
                section.tag = "Rating Questions"
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "sentRating"), object: nil, queue: .main) { (notif) in
            self.hideLoading()
            self.viewWillAppear?()
        }
    }
    
    func thankYouMessage(){
        let image1View = UIImageView(frame: CGRect(x: 0, y: self.tableView.bounds.midY-125, width: 418, height: 250))
        let image2View = UIImageView(frame: CGRect(x: self.tableView.bounds.midX - 198, y: self.tableView.bounds.midY - 165, width: 395, height: 330))
        image1View.image = UIImage.init(named: "bg threads for thank you")
        image2View.image = UIImage.init(named: "thankyou screens card - ios")
        //   self.tableView.backgroundView = view
        //        self.tableView.backgroundView = image1View
        //        self.tableView.backgroundView?.addSubview(image2View)
        self.tableView.addSubview(image1View)
        self.tableView.addSubview(image2View)
    }
    
    func reloadFormData() {
        
        if (User.loggedIn()?.refRoleId == "1" && self.isArtisanRatingDone == 0) || (User.loggedIn()?.refRoleId == "2" && self.isBuyerRatingDone == 0 ){
            let imageView = UIImageView(frame: CGRect(x: 0, y: UIScreen.main.bounds.midY-231, width: 414, height: 462))
            imageView.image = UIImage.init(named: "bg rating ")
            // self.tableView.backgroundView = view
            
            //  self.tableView.backgroundView = imageView
            //   self.form.sectionBy(tag: "Rating Questions").back
            imageView.frame = self.tableView.rect(forSection: 0)
            self.tableView.addSubview(imageView)
            let section = self.form.sectionBy(tag: "Rating Questions")
            if section?.isEmpty == true {
                self.ratingQuestionsFunc()
            }
            
        }
        if (User.loggedIn()?.refRoleId == "1" && self.isArtisanRatingDone == 1) || (User.loggedIn()?.refRoleId == "2" && self.isBuyerRatingDone == 1 ){
            
            let section = self.form.sectionBy(tag: "Rating Questions")
            section?.removeAll()
            //self.tableView.backgroundView?.removeFromSuperview()
            // self.tableView.backgroundView?.willRemoveSubview(imageView)
            self.thankYouMessage()
        }
    }
    
    func ratingQuestionsFunc(){
        if let ratingQuestionsSection = self.form.sectionBy(tag: "Rating Questions") {
            if allBuyerRatingQuestions != nil && allArtisanRatingQuestions != nil {
                let showBuyerRatingQuestions = allBuyerRatingQuestions!
                let showArtisanRatingQuestions = allArtisanRatingQuestions!
                if  self.isArtisanRatingDone == 0 || self.isBuyerRatingDone == 0{
                    ratingQuestionsSection  <<< LabelRow() {
                        $0.cell.height = {20.0}
                        $0.title = ""
                        }
                        <<< LabelRow() {
                            $0.title = "Rate the artisan"
                            if User.loggedIn()?.refRoleId == "1" {
                                $0.title = "Rate the buyer"
                            }
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                            cell.textLabel?.font = .systemFont(ofSize: 20, weight: .regular)
                        })
                        <<< GiveRatingRow() {
                            $0.cell.height = { 120.0 }
                            $0.tag = "Average Rating"
                            $0.cell.RatingLabel.text = "0.0"
                        }.cellUpdate({ (cell, row) in
                            cell.AvgTextLabel?.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                            cell.AvgTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                            var sum: Double = 0.0
                            for (_, value) in self.ratingDict{
                                sum += Double(value)
                            }
                            cell.RatingLabel.text = "\(sum/5.0)"
                        })
                }
                
                if User.loggedIn()?.refRoleId == "1" && self.isArtisanRatingDone == 0 {
                    
                    for object in showArtisanRatingQuestions {
                        
                        if object.answerType == 1  {
                            ratingQuestionsSection <<< LabelRow(){
                                $0.title = object.question
                                $0.cellStyle = .default
                                $0.cell.textLabel?.numberOfLines = 2
                                $0.cell.textLabel?.textAlignment = .center
                                $0.cell.textLabel?.center = self.view.center
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor =  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                                //cell.textLabel?.font = .systemFont(ofSize: 20, weight: .regular)
                            })
                            ratingQuestionsSection <<< RatingStarsRow() {
                                $0.cell.tag =  object.entityID
                                $0.tag = object.id!
                                $0.cell.height = { 50.0 }
                                $0.cell.StarsView.rating = 0.0
                                $0.cell.selectionStyle = .none
                                $0.cell.delegate = self
                            }
                        }
                    }
                    for object in showArtisanRatingQuestions {
                        
                        if object.answerType == 2 {
                            
                            ratingQuestionsSection <<< RatingTextFieldRow(){
                                $0.cell.height = { 225.0}
                                $0.cell.Label2.text = object.question
                            }
                            ratingQuestionsSection <<< TextAreaRow() {
                                $0.cell.height = {200.0}
                                $0.placeholder = "Type here...".localized
                                $0.cell.textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                                $0.cell.textView.layer.borderWidth = 1
                                self.viewModel.artisanComment.bidirectionalBind(to: $0.cell.textView.reactive.text)
                                $0.cell.textView.text = self.viewModel.artisanComment.value ?? ""
                                $0.value = self.viewModel.artisanComment.value ?? ""
                                
                            }.cellUpdate({ (cell, row) in
                                self.viewModel.artisanComment.value = cell.textView.text
                                cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                                cell.textView?.font = .systemFont(ofSize: 13, weight: .regular)
                                cell.textView?.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                            })
                        }
                    }
                    
                }
                
                if User.loggedIn()?.refRoleId == "2" && self.isBuyerRatingDone == 0 {
                    for object in showBuyerRatingQuestions {
                        
                        if object.answerType == 1  {
                            ratingQuestionsSection <<< LabelRow(){
                                $0.title = object.question
                                $0.cellStyle = .default
                                $0.cell.textLabel?.numberOfLines = 2
                                $0.cell.textLabel?.textAlignment = .center
                                $0.cell.textLabel?.center = self.view.center
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor =  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                                // cell.textLabel?.font = .systemFont(ofSize: 20, weight: .regular)
                            })
                            ratingQuestionsSection <<< RatingStarsRow() {
                                $0.cell.height = { 50.0 }
                                $0.cell.tag =  object.entityID
                                $0.tag = object.id!
                                $0.cell.StarsView.rating = 0.0
                                $0.cell.selectionStyle = .none
                                $0.cell.delegate = self
                            }
                        }
                    }
                    for object in showArtisanRatingQuestions {
                        
                        if object.answerType == 2 {
                            
                            ratingQuestionsSection <<< RatingTextFieldRow(){
                                $0.cell.height = { 225.0}
                                $0.cell.Label2.text = object.question
                            }
                            ratingQuestionsSection <<< TextAreaRow() {
                                $0.cell.height = {200.0}
                                $0.placeholder = "Type here...".localized
                                $0.cell.textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                                $0.cell.textView.layer.borderWidth = 1
                                self.viewModel.buyerComment.bidirectionalBind(to: $0.cell.textView.reactive.text)
                                $0.cell.textView.text = self.viewModel.buyerComment.value ?? ""
                                $0.value = self.viewModel.buyerComment.value ?? ""
                                
                            }.cellUpdate({ (cell, row) in
                                self.viewModel.buyerComment.value = cell.textView.text
                                cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                                cell.textView?.font = .systemFont(ofSize: 13, weight: .regular)
                                cell.textView?.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                            })
                        }
                    }
                    
                }
                
                ratingQuestionsSection <<< RoundedButtonViewRow() {
                    //   $0.tag = "Send review"
                    $0.cell.titleLabel.isHidden = true
                    $0.cell.compulsoryIcon.isHidden = true
                    $0.cell.greyLineView.isHidden = true
                    $0.cell.buttonView.borderColour = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    $0.cell.buttonView.setTitleColor(.white, for: .normal)
                    $0.cell.buttonView.setTitle("Submit", for: .normal)
                    $0.cell.buttonView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    $0.cell.tag = 101
                    $0.cell.height = { 80.0 }
                    $0.cell.delegate = self
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppear?()
    }
    
}

extension ProvideRatingController: ButtonActionProtocol, RatingStarsProtocol {
    
    func ratingSelected(tag: Int, rating: Double) {
        if User.loggedIn()?.refRoleId == "1" && self.isArtisanRatingDone == 0 {
            if  allArtisanRatingQuestions != nil {
                
                let showArtisanRatingQuestions = allArtisanRatingQuestions!
                showArtisanRatingQuestions.forEach({ (obj) in
                    switch tag {
                    case obj.entityID:
                        let row2 = self.form.rowBy(tag: "Average Rating")
                        self.ratingDict.updateValue(Int(rating * 2.0), forKey: obj.entityID)
                        row2?.reload()
                        
                    default:
                        print("do nothing")
                    }
                })
            }
        }
        
        if User.loggedIn()?.refRoleId == "2" && self.isBuyerRatingDone == 0 {
            if allBuyerRatingQuestions != nil {
                let showBuyerRatingQuestions = allBuyerRatingQuestions!
                showBuyerRatingQuestions.forEach({ (obj) in
                    switch tag {
                    case obj.entityID:
                        let row2 = self.form.rowBy(tag: "Average Rating")
                        self.ratingDict.updateValue(Int(rating * 2.0), forKey: obj.entityID)
                        row2?.reload()
                        
                    default:
                        print("do nothing")
                    }
                })
            }
            
        }
    }
    
    /// Rating submit button
    func customButtonSelected(tag: Int) {
        switch tag {
        case 101:
            
            if User.loggedIn()?.refRoleId == "1" && self.isArtisanRatingDone == 0 {
                if  allArtisanRatingQuestions != nil && allArtisanRatingQuestions?.filter("%K == %@", "answerType", 1).count == ratingDict.count  {
                    
                    for obj in allArtisanRatingQuestions! {
                        if obj.answerType == 1 {
                            sendRatingObj.append(artisanRating.init(enquiryId: orderObject?.enquiryId ?? 0, givenBy: KeychainManager.standard.userID ?? 0, questionId: obj.entityID, response: ratingDict[obj.entityID]!, responseComment: nil).toJSON())
                            
                        }
                        if obj.answerType == 2 && self.viewModel.artisanComment.value != "" {
                            sendRatingObj.append(artisanRating.init(enquiryId: orderObject?.enquiryId ?? 0, givenBy: KeychainManager.standard.userID ?? 0, questionId: obj.entityID, response: 0, responseComment: self.viewModel.artisanComment.value ?? nil).toJSON())
                            
                        }
                        
                        
                    }
                    print(sendRatingObj)
                    self.sendRating?(sendRatingObj)
                }else{
                    self.alert("Please give rating for all questions")
                }
                
                
            }
            
            if User.loggedIn()?.refRoleId == "2" && self.isBuyerRatingDone == 0 {
                if  allBuyerRatingQuestions != nil && allBuyerRatingQuestions?.filter("%K == %@", "answerType", 1).count == ratingDict.count  {
                    
                    for obj in allBuyerRatingQuestions! {
                        if obj.answerType == 1 {
                            sendRatingObj.append(artisanRating.init(enquiryId: orderObject?.enquiryId ?? 0, givenBy: KeychainManager.standard.userID ?? 0, questionId: obj.entityID, response: ratingDict[obj.entityID]!, responseComment: nil).toJSON())
                            
                        }
                        if obj.answerType == 2 && self.viewModel.buyerComment.value != "" {
                            sendRatingObj.append(artisanRating.init(enquiryId: orderObject?.enquiryId ?? 0, givenBy: KeychainManager.standard.userID ?? 0, questionId: obj.entityID, response: 0, responseComment: self.viewModel.buyerComment.value ?? nil).toJSON())
                            
                        }
                    }
                    print(sendRatingObj)
                    self.sendRating?(sendRatingObj)
                }else{
                    self.alert("Please give rating for all questions")
                }
            }
        default:
            print("do nothing")
        }
    }
}

