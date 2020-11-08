//
//  RaiseConcernController.swift
//  CraftExchange
//
//  Created by Kalyan on 03/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ViewRow
import WebKit

class RaiseConcernModel {
    var buyerComment = Observable<String?>(nil)
    var artisanComment = Observable<String?>(nil)
    var artisanReviewId = Observable<ArtisanFaultyOrder?>(nil)
    var buyerReviewId = Observable<String?>(nil)
    var viewDidLoad: (() -> Void)?
}

class RaiseConcernController: FormViewController {
    var orderObject: Order?
    var optionsArray:[Int] = []
    var viewWillAppear: (() -> ())?
    var getOrderProgress: (() -> ())?
    var sendBuyerReview: (() -> ())?
    var sendConfirmBuyerReview: (() -> ())?
    var sendArtisanReview: (() -> ())?
    var markResolved: (() -> ())?
    lazy var viewModel = RaiseConcernModel()
    var orderProgress: OrderProgress?
    var allBuyerReviews: Results<BuyerFaultyOrder>?
    var allArtisanReviews: Results<ArtisanFaultyOrder>?
    let realm = try? Realm()
    var needToRefreshView = false
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // self.getOrderProgress?()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        allBuyerReviews = realm!.objects(BuyerFaultyOrder.self).sorted(byKeyPath: "entityID")
        allArtisanReviews = realm!.objects(ArtisanFaultyOrder.self).sorted(byKeyPath: "entityID")
        
        let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        self.loadData()
        
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    func loadData() {
        
        
        form
            +++ Section()
            
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                $0.cell.statusLbl.text = ""
                $0.cell.faultyStrings.isHidden = false
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if orderObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = orderObject?.brandName
                }
                $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "\(orderObject?.totalAmount ?? 0)" : "NA"
                if let tag = orderObject?.productImages?.components(separatedBy: ",").first, let prodId = orderObject?.productId {
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
            }.cellUpdate({ (cell, row) in
                
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.statusLbl.text = "Report Fault"
                    cell.statusLbl.textColor = .systemRed
                    cell.statusDotView.backgroundColor = .systemRed
                }
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" {
                    cell.statusLbl.text = "Fault Unresolved"
                    cell.statusLbl.textColor = UIColor().CEGreen()
                    cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" {
                    cell.statusLbl.text = "Fault Raised"
                    cell.statusLbl.textColor = UIColor().CEGreen()
                    cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                if self.orderProgress?.isResolved == 1  {
                    cell.statusLbl.text = "Concern Resolved"
                    cell.statusLbl.textColor = UIColor().CEGreen()
                    cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                
                cell.dateLbl.text = ""
                
            })
            
            +++ Section()
            
            <<< LabelRow(){
                $0.tag = "Rate Order 1"
                // $0.cell.height = { 50.0 }
                $0.hidden = true
                if orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        $0.hidden = false
                    }
                }
                $0.title = """
                We're glad that your concern is
                resolved on mutual agreement
                """
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = UIColor().CEGreen()
                cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        cell.row.hidden = false
                    }
                }
            })
            <<< LabelRow(){
                $0.tag = "Rate Order 2"
                $0.cell.height = { 40.0 }
                $0.title = ""
                $0.hidden = true
                if orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        $0.hidden = false
                    }
                }
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        cell.row.hidden = false
                    }
                }
            })
            <<< SingleButtonRow() {
                $0.tag = "Rate Order 3"
                $0.cell.singleButton.backgroundColor = #colorLiteral(red: 0.2705882353, green: 0.1137254902, blue: 0.7058823529, alpha: 1)
                $0.cell.singleButton.setTitleColor(.white, for: .normal)
                $0.cell.singleButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                $0.cell.singleButton.setImage(UIImage.init(named: "Icon material-rate-review - white"), for: .normal)
                let frame: CGRect = $0.cell.singleButton.frame
                $0.cell.singleButton.frame = CGRect(x: (frame.size.width/2) - 150 , y: 0, width: 300, height: frame.size.height)
                $0.cell.singleButton.layer.cornerRadius = 25
                $0.cell.singleButton.setTitle("  Rate & review this order", for: .normal)
                $0.cell.height = { 50.0 }
                $0.hidden = true
                if orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        $0.hidden = false
                    }
                }
                $0.cell.delegate = self
                $0.cell.tag = 101
            }.cellUpdate({ (cell, row) in
                if self.orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        cell.row.hidden = false
                    }
                }
            })
            <<< LabelRow(){
                $0.tag = "Rate Order 4"
                $0.cell.height = { 10.0 }
                $0.title = ""
                $0.hidden = true
                if orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        $0.hidden = false
                    }
                }
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        cell.row.hidden = false
                    }
                }
            })
            
            <<< LabelRow(){
                $0.tag = "Rate Order 5"
                $0.cell.height = { 80.0 }
                $0.hidden = true
                if orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        $0.hidden = false
                    }
                }
                $0.title = "Great job!"
                $0.cellStyle = .default
                $0.cell.textLabel?.textAlignment = .center
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5098039216, blue: 0, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 32, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress != nil {
                    if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        cell.row.hidden = false
                    }
                }
            })
            
            
            +++ Section()
            <<< LabelRow(){
                $0.tag = "1"
                $0.cell.height = { 60.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = "Uh Oh!!!!"
                $0.cellStyle = .default
                $0.cell.textLabel?.textAlignment = .center
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 32, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "2"
                $0.cell.height = { 30.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = "Please let us know what went wrong so that we can take this up"
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            
            <<< LabelRow(){
                $0.tag = "3"
                $0.cell.height = { 60.0 }
                $0.title = ""
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "4"
                $0.cell.height = { 30.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = "Select if any of the options are relevent."
                // $0.cellStyle = .default
                $0.cell.textLabel?.textAlignment = .center
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "5"
                $0.cell.height = { 60.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = "Make sure to choose the right option or else choose 'Others' & simply describe your problem in comments below."
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "6"
                $0.cell.height = {30.0}
                $0.title = ""
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            
            +++ Section(){ section in
                section.tag = "list Buyer reviews"
            }
            
            //
            
            +++ Section()
            <<< LabelRow(){
                $0.tag = "7"
                $0.cell.height = {20.0}
                $0.title = ""
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "8"
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.cell.height = { 20.0 }
                $0.cellStyle = .default
                $0.title = "Description of the Problem(Mandatory)"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
                
            })
            <<< TextAreaRow() {
                $0.tag = "9"
                $0.cell.height = { 200.0 }
                $0.placeholder = "Type here...".localized
                $0.cell.textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                $0.cell.textView.layer.borderWidth = 1
                self.viewModel.buyerComment.bidirectionalBind(to: $0.cell.textView.reactive.text)
                $0.cell.textView.text = self.viewModel.buyerComment.value ?? ""
                $0.value = self.viewModel.buyerComment.value ?? ""
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                // cell.textView.delegate = self
                self.viewModel.buyerComment.value = cell.textView.text
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            
            <<< LabelRow(){
                $0.tag = "10"
                $0.cell.height = {10.0}
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = ""
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "11"
                $0.cell.height = { 20.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = "Plese note:"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .bold)
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "12"
                // $0.cell.height = { 70.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = "Hand made products are prone to few minor defects, which makes it unique to the style & tradition of the culture. Also it is mark of authenticity. We humbly request you to respect & trust the artsans' on the same before raising any concern."
                
                $0.cell.textLabel?.numberOfLines = 5
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "13"
                $0.cell.height = {20.0}
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = ""
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< RoundedButtonViewRow() {
                $0.tag = "14"
                //   $0.tag = "Send review"
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Submit", for: .normal)
                $0.cell.buttonView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                //  $0.cell.buttonView
                var frame: CGRect = $0.cell.buttonView.frame
                frame.size.height = 45
                //                    $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = 101
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
                
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "15"
                $0.cell.height = {20.0}
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
                $0.title = ""
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            
            <<< RoundedButtonViewRow() {
                $0.tag = "16"
                $0.cell.contentView.backgroundColor = #colorLiteral(red: 0.9198423028, green: 0.9198423028, blue: 0.9198423028, alpha: 1)
                //   $0.tag = "go to chat"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.tintColor = .white
                $0.cell.buttonView.setTitle("", for: .normal)
                
                $0.cell.buttonView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                $0.cell.buttonView.setImage( UIImage.init(named: "ios magenta chat"), for: .normal)
                $0.cell.tag = 103
                $0.cell.height = { 70.0 }
                $0.cell.delegate = self
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "17"
                $0.cell.height = { 60.0 }
                $0.cell.contentView.backgroundColor = #colorLiteral(red: 0.9198423028, green: 0.9198423028, blue: 0.9198423028, alpha: 1)
                $0.title = "Upload photos (IN CHAT) for reference"
                $0.cellStyle = .value2
                // $0.cell.textLabel?.textAlignment = .center
                // $0.cell.textLabel?.numberOfLines = 3
                $0.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                row.cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                    cell.row.hidden = false
                }
            })
            
            
            
            
            +++ Section()
            <<< LabelRow(){
                $0.tag = "18"
                $0.cell.height = { 60.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                $0.title = "Please bear. it may take upto 48 hours for Admin to adress & respond to your raised concern."
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
            })
            
            <<< LabelRow() {
                $0.tag = "View defect & Response buyer"
                //  $0.tag = "4"
                $0.cell.height = { 44.0 }
                $0.title = "View defect & Response ⋀".localized
                $0.hidden = true
                if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2") {
                    $0.hidden = false
                }
                
                $0.cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                $0.cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                // $0.cell.valueLbl.textColor = UIColor().EQGreenText()
            }.onCellSelection({ (cell, row) in
                let section = self.form.sectionBy(tag: "Buyer sent reviews")
                if section?.isEmpty == true {
                    self.buyerSentReviewsFunc()
                    //    section?.hidden = false
                    section?.reload()
                    // self.form.allSections.first?.reload(with: .none)
                    row.reload()
                }else {
                    section?.removeAll()
                    section?.reload()
                    // self.form.allSections.first?.reload(with: .none)
                    row.reload()
                }
                // section?.reload()
                self.form.allSections.forEach { (section) in
                    section.reload()
                }
                
            }).cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                let section = self.form.sectionBy(tag: "Buyer sent reviews")
                if section?.isEmpty == true {
                    row.title = "View defect & Response ⋁".localized
                }else {
                    row.title = "View defect & Response ⋀".localized
                }
                // row.hidden = true
                if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2") {
                    cell.row.hidden = false
                }
                
            })
            
            +++ Section(){ section in
                section.tag = "Buyer sent reviews"
                //                section.hidden = true
                //                if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2") {
                //                    section.hidden = false
                //                }
                
            }
            +++ Section()
            
            <<< ProFormaInvoiceRow() {
                $0.cell.height = { 85.0 }
                $0.cell.delegate = self
                $0.tag = "Mark Resolved"
                $0.cell.tag = 101
                $0.cell.nextStepsLabel.text = "Is concern resolved?"
                $0.cell.createSendInvoiceBtn.setTitle("Mark concern resolved", for: .normal)
                $0.cell.createSendInvoiceBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5098039216, blue: 0, alpha: 1)
                $0.cell.createSendInvoiceBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                $0.hidden = true
                if orderObject != nil {
                    if self.orderProgress?.isResolved == 0  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        $0.hidden = false
                    }
                }
                
            }.cellUpdate({ (cell, row) in
                if self.orderObject != nil {
                    if self.orderProgress?.isResolved == 0  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                        cell.row.hidden = false
                    }else{
                        cell.row.hidden = true
                        cell.height = { 0.0 }
                    }
                }
            })
            
            +++ Section()
            <<< LabelRow(){
                $0.tag = "19"
                $0.cell.height = { 60.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                $0.title = "We've escalated the issue to admin on priority. you shall receive response on your phone or email."
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
            })
            
            
            
            +++ Section()
            <<< LabelRow(){
                $0.tag = "21"
                $0.cell.height = { 40.0 }
                
                $0.hidden = true
                
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                $0.title = "Please acknowledge the raised concern to avoid any escalations."
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
            })
            <<< LabelRow(){
                $0.tag = "22"
                $0.cell.height = { 40.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                $0.title = "Please reply before 48 hours for raised concern."
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
            })
            
            //      +++ Section()
            <<< LabelRow() {
                $0.tag = "View defect & Response artisan"
                //  $0.tag = "4"
                $0.cell.height = { 44.0 }
                $0.title = "View defect & Response ⋀".localized
                $0.hidden = true
                if (self.orderProgress?.isFaulty == 1  && self.orderProgress?.artisanReviewComment != nil && User.loggedIn()?.refRoleId == "1") {
                    $0.hidden = false
                }
                
                //  $0.cell.valueLbl.text = ""
                //   $0.cell.contentView.backgroundColor = .white
                $0.cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                $0.cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                // $0.cell.valueLbl.textColor = UIColor().EQGreenText()
            }.onCellSelection({ (cell, row) in
                let section = self.form.sectionBy(tag: "Buyer sent reviews to artisan")
                if section?.isEmpty == true {
                    self.buyerSentReviewsArtisanFunc()
                    section?.reload()
                    // self.form.allSections.first?.reload(with: .none)
                    row.reload()
                }else {
                    section?.removeAll()
                    section?.reload()
                    //  self.form.allSections.first?.reload(with: .none)
                    row.reload()
                }
                section?.reload()
                self.form.allSections.forEach { (section) in
                    section.reload()
                }
                // self.form.allSections.first?.reload(with: .none)
                
            }).cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                let section = self.form.sectionBy(tag: "Buyer sent reviews to artisan")
                if section?.isEmpty == true {
                    row.title = "View defect & Response ⋁".localized
                }else {
                    row.title = "View defect & Response ⋀".localized
                }
                // row.hidden = true
                if (self.orderProgress?.isFaulty == 1  && self.orderProgress?.artisanReviewComment != nil && User.loggedIn()?.refRoleId == "1") {
                    cell.row.hidden = false
                }
                
            })
            
            +++ Section(){ section in
                section.tag = "Buyer sent reviews to artisan"
            }
            
            
            +++ Section()
            
            <<< RoundedButtonViewRow() {
                $0.tag = "24"
                //   $0.tag = "go to chat 2"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.tintColor = .white
                $0.cell.buttonView.setTitle("", for: .normal)
                
                $0.cell.buttonView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                $0.cell.buttonView.setImage( UIImage.init(named: "ios magenta chat"), for: .normal)
                $0.cell.tag = 103
                $0.cell.height = { 120.0 }
                $0.cell.delegate = self
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
                
            })
            
            
            <<< LabelRow() {
                $0.tag = "25"
                $0.cell.height = { 44.0 }
                $0.title = "Remarks by Artisan Entrepreneur".localized
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
                
            })
            
            <<< RoundedActionSheetRow() {
                $0.tag = "26"
                //  $0.tag = "Artisan Review"
                $0.cell.titleLabel.text = "Select action"
                $0.cell.titleLabel.textColor = .black
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.options = allArtisanReviews?.compactMap { $0.comment }
                $0.cell.actionButton.setTitleColor(.black, for: .normal)
                $0.cell.actionButton.cornerRadius = 0
                self.viewModel.artisanReviewId.value = ArtisanFaultyOrder.getReviewType(searchId: orderProgress?.artisanReviewId ?? "0")
                if let selectedTiming = self.viewModel.artisanReviewId.value {
                    $0.cell.selectedVal = selectedTiming.comment
                    $0.value = selectedTiming.comment
                }
                $0.cell.actionButton.setTitle("Action: " + ($0.value ?? ""), for: .normal)
                $0.cell.delegate = self
                $0.cell.height = { 80.0 }
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                
                
            }.onChange({ (row) in
                print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
                let selectedTimingObj = self.allArtisanReviews?.filter({ (obj) -> Bool in
                    obj.comment == row.value
                }).first
                row.cell.actionButton.setTitle("Action: " + (row.value ?? ""), for: .normal)
                
                self.viewModel.artisanReviewId.value = selectedTimingObj
            }).cellUpdate({ (cell, row) in
                
                if let selectedTiming = self.viewModel.artisanReviewId.value {
                    cell.selectedVal = selectedTiming.comment
                    cell.row.value = selectedTiming.comment
                }
                cell.actionButton.setTitle("Action: " + (cell.row.value ?? ""), for: .normal)
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
                
            })
            
            <<< TextAreaRow() {
                $0.tag = "27"
                $0.cell.height = { 200.0 }
                $0.placeholder = "Add your comment".localized
                $0.cell.textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                $0.cell.textView.layer.borderWidth = 1
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                
                self.viewModel.artisanComment.bidirectionalBind(to: $0.cell.textView.reactive.text)
                $0.cell.textView.text = self.viewModel.artisanComment.value ?? ""
                $0.value = self.viewModel.artisanComment.value ?? ""
            }.cellUpdate({ (cell, row) in
                // cell.textView.delegate = self
                self.viewModel.artisanComment.value = cell.textView.text
                //  row.cell.contentView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
                
            })
            
            
            <<< LabelRow(){
                $0.tag = "28"
                $0.cell.height = {10.0}
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                
                $0.title = ""
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
                
            })
            
            
            <<< RoundedButtonViewRow() {
                $0.tag = "29"
                //  $0.tag = "Send Artisan review"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = #colorLiteral(red: 0.1133080051, green: 0.262307363, blue: 0.7459332192, alpha: 1)
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Send", for: .normal)
                $0.cell.buttonView.backgroundColor = #colorLiteral(red: 0.1133080051, green: 0.262307363, blue: 0.7459332192, alpha: 1)
                //                    $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = 102
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
                $0.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    $0.hidden = false
                }
                
                
            }.cellUpdate({ (cell, row) in
                // row.hidden = true
                if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                    cell.row.hidden = false
                }
                
            })
        
        if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
            self.buyerReviewsFunc()
        }
        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2") {
            self.buyerSentReviewsFunc()
        }
        if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" {
            self.buyerSentReviewsArtisanFunc()
        }
        
        
    }
    
    func reloadFormData() {
        
        if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
            for num in 1...17 {
                self.form.rowBy(tag: "\(num)")?.hidden = false
                self.form.rowBy(tag: "\(num)")?.evaluateHidden()
                self.form.rowBy(tag: "\(num)")?.reload()
                
            }
            let section = self.form.sectionBy(tag: "list Buyer reviews")
            if section?.isEmpty == true {
                self.buyerReviewsFunc()
            }
            
        }else{
            for num in 1...17 {
                self.form.rowBy(tag: "\(num)")?.hidden = true
                self.form.rowBy(tag: "\(num)")?.evaluateHidden()
                self.form.rowBy(tag: "\(num)")?.reload()
                
            }
            let section = self.form.sectionBy(tag: "list Buyer reviews")
            if section?.isEmpty == false {
                section?.removeAll()
            }
        }
        
        
        if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2"{
            let row = self.form.rowBy(tag: "View defect & Response buyer")
            row?.hidden = false
            row?.evaluateHidden()
            row?.reload()
            
            let section = self.form.sectionBy(tag: "Buyer sent reviews")
            if section?.isEmpty == true {
                self.buyerSentReviewsFunc()
            }
            if self.orderProgress?.artisanReviewComment == nil {
                for num in 18...19 {
                    self.form.rowBy(tag: "\(num)")?.hidden = false
                    self.form.rowBy(tag: "\(num)")?.evaluateHidden()
                    self.form.rowBy(tag: "\(num)")?.reload()
                    
                }
                
            }
            else {
                for num in 18...19 {
                    self.form.rowBy(tag: "\(num)")?.hidden = true
                    self.form.rowBy(tag: "\(num)")?.evaluateHidden()
                    self.form.rowBy(tag: "\(num)")?.reload()
                }
            }
        }
        else{
            let row = self.form.rowBy(tag: "View defect & Response buyer")
            row?.hidden = true
            row?.evaluateHidden()
            row?.reload()
            
        }
        if orderProgress != nil {
            if self.orderProgress?.isResolved == 0  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                let row = self.form.rowBy(tag: "Mark Resolved")
                row?.hidden = false
                row?.evaluateHidden()
                row?.reload()
            }else{
                let row = self.form.rowBy(tag: "Mark Resolved")
                row?.hidden = true
                row?.evaluateHidden()
                row?.reload()
            }
            
        }
        
        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1"){
            
            
            if self.orderProgress?.artisanReviewComment != nil {
                for num in 21...29 {
                    self.form.rowBy(tag: "\(num)")?.hidden = true
                    self.form.rowBy(tag: "\(num)")?.evaluateHidden()
                    self.form.rowBy(tag: "\(num)")?.reload()
                    
                }
                let row = self.form.rowBy(tag: "View defect & Response artisan")
                row?.hidden = false
                row?.evaluateHidden()
                row?.reload()
                let section = self.form.sectionBy(tag: "Buyer sent reviews to artisan")
                section?.removeAll()
                self.buyerSentReviewsArtisanFunc()
                
            }
            else{
                let section = self.form.sectionBy(tag: "Buyer sent reviews to artisan")
                if section?.isEmpty == true{
                    self.buyerSentReviewsArtisanFunc()
                }
                
                for num in 21...29 {
                    self.form.rowBy(tag: "\(num)")?.hidden = false
                    self.form.rowBy(tag: "\(num)")?.evaluateHidden()
                    self.form.rowBy(tag: "\(num)")?.reload()
                    
                }
                
            }
        }
        if orderProgress != nil {
            if self.orderProgress?.isResolved == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil {
                
                for num in 1...5 {
                    self.form.rowBy(tag: "Rate Order \(num)")?.hidden = false
                    self.form.rowBy(tag: "Rate Order \(num)")?.evaluateHidden()
                    self.form.rowBy(tag: "Rate Order \(num)")?.reload()
                }
                
            }
            
        }
        
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
    }
    
    
    func buyerReviewsFunc() {
        if let listMOQSection = self.form.sectionBy(tag: "list Buyer reviews") {
            if allBuyerReviews != nil {
                let showBuyerReviews = allBuyerReviews!
                showBuyerReviews.forEach({ (obj) in
                    listMOQSection <<< BuyerFaultyOrderOptionRow() {
                        $0.cell.height = {90.0}
                        $0.tag = obj.comment!
                        $0.hidden = true
                        if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                            $0.hidden = false
                        }
                        $0.cell.reviewLabel.text = obj.subComment
                        $0.cell.reviewOptionButton.setTitle(obj.comment, for: .normal)
                        $0.cell.reviewOptionButton.tag = obj.entityID
                        $0.cell.tag = obj.entityID
                        $0.cell.delegate = self
                    }.cellUpdate({ (cell, row) in
                        // row.hidden = true
                        if self.orderProgress?.isFaulty == 0  && User.loggedIn()?.refRoleId == "2" {
                            cell.row.hidden = false
                        }
                    })
                })
                self.form.sectionBy(tag: "list Buyer reviews")?.reload()
                self.form.allSections.forEach { (section) in
                    section.reload()
                }
            }
            
        }
    }
    
    func buyerSentReviewsFunc() {
        if let listBuyerSentReviewSection = self.form.sectionBy(tag: "Buyer sent reviews") {
            if allBuyerReviews != nil && orderProgress?.buyerReviewComment != nil{
                let showBuyerReviews = allBuyerReviews!
                showBuyerReviews.forEach({ (obj) in
                    if (orderProgress?.buyerReviewId!.contains(obj.id))! {
                        listBuyerSentReviewSection <<< BuyerFaultyOrderOptionRow() {
                            $0.cell.height = {65.0}
                            //$0.tag = obj.comment! + "2"
                            $0.hidden = true
                            if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2"{
                                $0.hidden = false
                            }
                            $0.cell.reviewLabel.text = ""
                            $0.cell.reviewOptionButton.setTitle(obj.comment, for: .normal)
                            $0.cell.reviewOptionButton.setTitleColor(.black, for: .normal)
                            $0.cell.reviewOptionButton.isUserInteractionEnabled = false
                            $0.cell.reviewOptionButton.tag = obj.entityID
                            //   $0.cell.tag = obj.entityID
                            //  $0.cell.delegate = self
                        }.cellUpdate({ (cell, row) in
                            if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2"{
                                cell.row.hidden = false
                            }
                            
                        })
                    }
                })
                listBuyerSentReviewSection <<< LabelRow(){
                    // $0.cell.height = { 30.0 }
                    $0.hidden = true
                    if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2"{
                        $0.hidden = false
                    }
                    $0.title = orderProgress?.buyerReviewComment?.localized
                    $0.cell.textLabel?.numberOfLines = 15
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    // row.cell.separatorInset = UIEdgeInsets(top: 60, left: 30, bottom: 0, right: 30)
                    row.cell.contentView.layoutMargins = UIEdgeInsets(top: 60, left: 30, bottom: 0, right: 30)
                    cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    cell.textLabel?.textAlignment = .justified
                    
                    if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2"{
                        cell.row.hidden = false
                    }
                    
                })
                if self.orderProgress?.artisanReviewComment != nil {
                    listBuyerSentReviewSection <<< LabelRow() {
                        $0.cell.height = { 44.0 }
                        $0.title = "Remarks by Artisan Entrepreneur".localized
                        $0.hidden = true
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            $0.hidden = false
                        }
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor =  #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            cell.row.hidden = false
                        }
                    })
                    
                    listBuyerSentReviewSection <<< RoundedActionSheetRow() {
                        //  $0.tag = "Artisan Review"
                        $0.cell.titleLabel.text = "Selected action"
                        $0.cell.titleLabel.textColor = .black
                        $0.cell.compulsoryIcon.isHidden = true
                        $0.cell.options = allArtisanReviews?.compactMap { $0.comment }
                        $0.cell.actionButton.setTitleColor(.black, for: .normal)
                        $0.cell.actionButton.cornerRadius = 0
                        $0.cell.height = { 80.0 }
                        $0.cell.isUserInteractionEnabled = false
                        $0.cell.actionButton.setTitle("Action: " + (ArtisanFaultyOrder.getReviewType(searchId: orderProgress?.artisanReviewId ?? "1")?.comment ?? ""), for: .normal)
                        $0.hidden = true
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            $0.hidden = false
                        }
                    }.cellUpdate({ (cell, row) in
                        row.cell.isUserInteractionEnabled = false
                        row.cell.actionButton.setTitle("Action: " + (ArtisanFaultyOrder.getReviewType(searchId: self.orderProgress?.artisanReviewId ?? "1")?.comment ?? ""), for: .normal)
                        
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            cell.row.hidden = false
                        }
                    })
                    
                    
                    listBuyerSentReviewSection  <<< LabelRow(){
                        $0.cell.height = { 10.0 }
                        $0.title = "Note".localized
                        $0.hidden = true
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            $0.hidden = false
                        }
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor =  #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                        
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            cell.row.hidden = false
                        }
                    })
                    
                    
                    listBuyerSentReviewSection  <<< LabelRow(){
                        $0.hidden = true
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            $0.hidden = false
                        }
                        $0.title = orderProgress?.artisanReviewComment?.localized
                        $0.cell.textLabel?.numberOfLines = 15
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = .black
                        cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                        cell.textLabel?.textAlignment = .justified
                        
                        if (self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "2" && self.orderProgress?.artisanReviewComment != nil){
                            cell.row.hidden = false
                        }
                        
                    })
                    listBuyerSentReviewSection  <<< LabelRow(){
                        $0.cell.height = {10.0}
                        
                        $0.title = ""
                    }
                    
                }
                
                
                self.form.sectionBy(tag: "Buyer sent reviews")?.reload()
                self.form.allSections.forEach { (section) in
                    section.reload()
                }
            }
            
        }
    }
    
    func buyerSentReviewsArtisanFunc() {
        if   let listBuyerSentReviewSection = self.form.sectionBy(tag: "Buyer sent reviews to artisan") {
            if allBuyerReviews != nil && self.orderProgress?.buyerReviewComment != nil{
                let showBuyerReviews = allBuyerReviews!
                listBuyerSentReviewSection  <<< LabelRow(){
                    $0.tag = "23"
                    $0.cell.height = { 60.0 }
                    $0.hidden = true
                    if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                        $0.hidden = false
                    }
                    $0.title = "Description of the fault"
                    // $0.cellStyle = .default
                    $0.cell.textLabel?.textAlignment = .center
                    $0.cell.textLabel?.numberOfLines = 3
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                    cell.textLabel?.textAlignment = .center
                    // row.hidden = true
                    if self.orderProgress?.isFaulty == 1  && User.loggedIn()?.refRoleId == "1" && self.orderProgress?.artisanReviewComment == nil {
                        cell.row.hidden = false
                    }
                })
                showBuyerReviews.forEach({ (obj) in
                    
                    if (orderProgress?.buyerReviewId!.contains(obj.id))! {
                        
                        listBuyerSentReviewSection <<< LabelRow(){
                            $0.cell.height = { 30.0 }
                            $0.title = obj.comment
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                            
                        })
                    }
                    
                })
                listBuyerSentReviewSection <<< LabelRow(){
                    $0.cell.height = {20.0}
                    $0.title = ""
                }
                
                listBuyerSentReviewSection <<< LabelRow(){
                    $0.cell.height = { 10.0 }
                    $0.title = "Note".localized
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                    cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                    
                })
                
                
                listBuyerSentReviewSection  <<< LabelRow(){
                    
                    $0.title = orderProgress?.buyerReviewComment?.localized
                    $0.cell.textLabel?.numberOfLines = 15
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                    cell.textLabel?.textAlignment = .justified
                    
                })
                
                if self.orderProgress?.artisanReviewComment != nil {
                    listBuyerSentReviewSection <<< LabelRow() {
                        $0.cell.height = { 44.0 }
                        $0.title = "Remarks by Artisan Entrepreneur".localized
                        
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5103793144, blue: 0, alpha: 1)
                        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                    })
                    
                    listBuyerSentReviewSection <<< RoundedActionSheetRow() {
                        //  $0.tag = "Artisan Review"
                        $0.cell.titleLabel.text = "Selected action"
                        $0.cell.titleLabel.textColor = .black
                        $0.cell.compulsoryIcon.isHidden = true
                        $0.cell.options = allArtisanReviews?.compactMap { $0.comment }
                        $0.cell.actionButton.setTitleColor(.black, for: .normal)
                        $0.cell.actionButton.cornerRadius = 0
                        $0.cell.height = { 80.0 }
                        $0.cell.isUserInteractionEnabled = false
                        $0.cell.actionButton.setTitle("Action: " + (ArtisanFaultyOrder.getReviewType(searchId: orderProgress!.artisanReviewId!)?.comment ?? ""), for: .normal)
                        
                    }.cellUpdate({ (cell, row) in
                        row.cell.isUserInteractionEnabled = false
                        row.cell.actionButton.setTitle("Action: " + (ArtisanFaultyOrder.getReviewType(searchId: self.orderProgress!.artisanReviewId!)?.comment ?? ""), for: .normal)
                        
                    })
                    
                    
                    listBuyerSentReviewSection  <<< LabelRow(){
                        $0.cell.height = { 10.0 }
                        $0.title = "Note".localized
                        $0.hidden = true
                        if self.orderProgress?.artisanReviewComment != nil {
                            $0.hidden = false
                        }
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                        if self.orderProgress?.artisanReviewComment != nil {
                            cell.row.hidden = false
                        }
                    })
                    
                    
                    listBuyerSentReviewSection  <<< LabelRow(){
                        $0.hidden = true
                        if self.orderProgress?.artisanReviewComment != nil {
                            $0.hidden = false
                        }
                        $0.title = orderProgress?.artisanReviewComment?.localized
                        $0.cell.textLabel?.numberOfLines = 15
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = .black
                        cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                        cell.textLabel?.textAlignment = .justified
                        if self.orderProgress?.artisanReviewComment != nil {
                            cell.row.hidden = false
                        }
                        
                    })
                    listBuyerSentReviewSection  <<< LabelRow(){
                        $0.cell.height = {10.0}
                        
                        $0.title = ""
                    }
                    
                }
                self.form.sectionBy(tag: "Buyer sent reviews to artisan")?.reload()
                //self.form.allSections.first?.reload(with: .none)
                self.form.allSections.forEach { (section) in
                    section.reload()
                }
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        viewWillAppear?()
        
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

extension RaiseConcernController: ButtonActionProtocol, BuyerFaultyOrderOptionProtocol, BuyerReviewConfirmViewProtocol, InvoiceButtonProtocol, CloseOrderViewProtocol, SingleButtonActionProtocol, PartialRefundReceivedViewProtocol{
    
    ///recreate order confirmation
    func RefundCancelButtonSelected() {
        self.view.hidePartialRefundReceivedView()
        self.viewWillAppear?()
    }
    
    func RefundNoButtonSelected() {
        self.view.hidePartialRefundReceivedView()
        self.viewWillAppear?()
    }
    
    func RefundYesButtonSelected() {
        if orderObject != nil && orderObject?.enquiryId != nil{
            let client = try! SafeClient(wrapping: CraftExchangeClient())
            let service = OrderDetailsService.init(client: client)
            self.showLoading()
            service.recreateOrderFunc(vc: self, enquiryId: orderObject!.enquiryId)
        }
        
        
    }
    
    
    ///rate & review order
    func singleButtonSelected(tag: Int) {
        switch tag {
        case 101:
            print("do nothing")
        default:
            print("do nothing")
        }
    }
    
    
    ///Mark concern resolved
    func closeOrderCancelButtonSelected() {
        self.view.hideCloseOrderView()
    }
    
    func closeOrderNoButtonSelected() {
        self.view.hideCloseOrderView()
    }
    
    func closeOrderYesButtonSelected() {
        self.markResolved?()
    }
    
    ///Mark concern resolved popup
    func createSendInvoiceBtnSelected(tag: Int) {
        switch tag {
        case 101:
            self.view.showCloseOrderView(controller: self, enquiryCode: orderObject?.orderCode, confirmStatement: "You are about to mark concern resolved!")
        default:
            print("do nothing")
        }
    }
    
    /// selecting options for review from buyer end
    func reviewOptionBtnSelected(tag: Int) {
        
        if allBuyerReviews != nil {
            let showBuyerReviews = allBuyerReviews!
            showBuyerReviews.forEach({ (obj) in
                switch tag {
                case obj.entityID:
                    let row = self.form.rowBy(tag: obj.comment!) as! BuyerFaultyOrderOptionRow
                    print(row.cell.buttonIsSelected)
                    if row.cell.buttonIsSelected == true {
                        if optionsArray != [] {
                            var i = 0
                            for name in optionsArray {
                                if name == obj.entityID {
                                    i = 1
                                }
                            }
                            if i == 0{
                                self.optionsArray.append(obj.entityID)
                            }
                            
                        }else{
                            self.optionsArray.append(obj.entityID)
                        }
                        
                    }else{
                        if let firstIndex = optionsArray.firstIndex(of: obj.entityID) {
                            optionsArray.remove(at: firstIndex)
                        }
                    }
                    
                default:
                    print("do nothing")
                }
            })
        }
        
    }
    /// sending review and response
    func customButtonSelected(tag: Int) {
        switch tag {
        case 101:
          //  print(optionsArray)
           // print(self.viewModel.buyerComment.value)
            var str = ""
            
            for id in optionsArray
            {
                let firstIndex = optionsArray.firstIndex(of: id)
                if firstIndex == 0{
                    str += "\(id)"
                }else{
                    str += ",\(id)"
                }
                
            }
            self.viewModel.buyerReviewId.value = str
//            print(self.viewModel.buyerReviewId.value)
            self.sendBuyerReview?()
            
            
        case 102:
//            print(self.viewModel.artisanReviewId.value?.id)
//            print(self.viewModel.artisanComment.value)
            self.sendArtisanReview?()
        case 103:
            self.goToChat()
        default:
            print("do nothing")
        }
    }
    
    ///send buyer review confirmation popup
    func closeBuyerReviewConfirmSelected() {
        self.view.hideBuyerReviewConfirmView()
    }
    
    func cancelBuyerReviewConfirmSelected() {
        self.view.hideBuyerReviewConfirmView()
    }
    
    func confirmSendingBuyerReviewSelected() {
        self.sendConfirmBuyerReview?()
    }
    
    
    
}
