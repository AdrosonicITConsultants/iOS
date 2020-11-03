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
    var additionalNote = Observable<String?>(nil)
    }

class RaiseConcernController: FormViewController {
    var orderObject: Order?
    var optionsArray:[Int] = []
    lazy var viewModel = RaiseConcernModel()
    var allBuyerReviews: Results<BuyerFaultyOrder>?
    var allArtisanReviews: Results<ArtisanFaultyOrder>?
    
    let realm = try? Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        allBuyerReviews = realm!.objects(BuyerFaultyOrder.self).sorted(byKeyPath: "entityID")
        allArtisanReviews = realm!.objects(ArtisanFaultyOrder.self).sorted(byKeyPath: "entityID")
        
        
        
        form
            +++ Section()
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                let image2View = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 116))
                image2View.image = UIImage.init(named: "faulty strings")
                
                $0.cell.backgroundView = image2View
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
                cell.statusLbl.text = "\(EnquiryStages.getStageType(searchId: self.orderObject?.enquiryStageId ?? 0)?.stageDescription ?? "-")"
                if self.orderObject?.enquiryStageId ?? 0 < 5 {
                    cell.statusLbl.textColor = .black
                    cell.statusDotView.backgroundColor = .black
                }else if self.orderObject?.enquiryStageId ?? 0 < 9 {
                    cell.statusLbl.textColor = .systemYellow
                    cell.statusDotView.backgroundColor = .systemYellow
                }else {
                    cell.statusLbl.textColor = UIColor().CEGreen()
                    cell.statusDotView.backgroundColor = UIColor().CEGreen()
                }
                if let date = self.orderObject?.lastUpdated {
                    cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
                }
            })
            <<< LabelRow(){
                $0.cell.height = { 60.0 }
                
                $0.title = "Uh Oh!!!!"
               // $0.cellStyle = .default
                $0.cell.textLabel?.textAlignment = .center
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 32, weight: .regular)
                cell.textLabel?.textAlignment = .center
            })
            <<< LabelRow(){
                $0.cell.height = { 30.0 }
                
                $0.title = "Please let us know what went wrong so that we can take this up"
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
            })
            
            <<< LabelRow(){
                $0.cell.height = { 60.0 }
                $0.title = ""
            }
            <<< LabelRow(){
                $0.cell.height = { 30.0 }
                
                $0.title = "Select if any of the options are relevent."
               // $0.cellStyle = .default
                $0.cell.textLabel?.textAlignment = .center
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
                cell.textLabel?.textAlignment = .center
            })
            <<< LabelRow(){
                $0.cell.height = { 60.0 }
                
                $0.title = "Make sure to choose the right option or else choose 'Others' & simply describe your problem in comments below."
                $0.cellStyle = .default
                $0.cell.textLabel?.numberOfLines = 3
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
                cell.textLabel?.textAlignment = .center
            })
            
            +++ Section(){ section in
                section.tag = "list Buyer reviews"
            }
            <<< LabelRow(){
                $0.cell.height = {30.0}
                $0.title = ""
                
            }
            //
            
            +++ Section()
            <<< LabelRow(){
                $0.cell.height = {20.0}
                $0.title = ""
                
            }
            <<< LabelRow(){
                $0.cell.height = { 20.0 }
                $0.cellStyle = .default
                $0.title = "Description of the Problem(Mandatory)"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
                cell.textLabel?.textAlignment = .center
                
            })
            <<< TextAreaRow() {
                $0.cell.height = { 200.0 }
                $0.placeholder = "Type here...".localized
                $0.cell.textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                $0.cell.textView.layer.borderWidth = 1
                self.viewModel.additionalNote.bidirectionalBind(to: $0.cell.textView.reactive.text)
                $0.cell.textView.text = self.viewModel.additionalNote.value ?? ""
                $0.value = self.viewModel.additionalNote.value ?? ""
            }.cellUpdate({ (cell, row) in
               // cell.textView.delegate = self
                self.viewModel.additionalNote.value = cell.textView.text
                })
           
            <<< LabelRow(){
                $0.cell.height = {10.0}
                
                $0.title = ""
            }
            <<< LabelRow(){
                $0.cell.height = { 20.0 }
                
                $0.title = "Plese note:"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .bold)
                
            })
            <<< LabelRow(){
                // $0.cell.height = { 70.0 }
                
                $0.title = "Hand made products are prone to few minor defects, which makes it unique to the style & tradition of the culture. Also it is mark of authenticity. We humbly request you to respect & trust the artsans' on the same before raising any concern."
                
                $0.cell.textLabel?.numberOfLines = 5
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 13, weight: .regular)
                
            })
            <<< LabelRow(){
                $0.cell.height = {40.0}
                
                $0.title = ""
            }
            
            <<< SingleButtonRow() {
                $0.tag = "Send review"
                $0.cell.singleButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                $0.cell.singleButton.setTitleColor(.white, for: .normal)
                $0.cell.singleButton.setTitle("Submit", for: .normal)
                $0.cell.height = { 50.0 }
                $0.cell.delegate = self as SingleButtonActionProtocol
                $0.cell.tag = 101
                //$0.hidden = true
            }.cellUpdate({ (cell, row) in
                //            if self.sentMOQ == 1{
                //                cell.isHidden = true
                //                cell.height = { 0.0 }
                //            }
            })
        
        self.buyerReviewsFunc()
        
    }
    func buyerReviewsFunc() {
        let listMOQSection = self.form.sectionBy(tag: "list Buyer reviews")!
        if allBuyerReviews != nil {
            let showBuyerReviews = allBuyerReviews!
            showBuyerReviews.forEach({ (obj) in
                listMOQSection <<< BuyerFaultyOrderOptionRow() {
                    $0.cell.height = {90.0}
                    $0.tag = obj.comment
                    $0.cell.reviewLabel.text = obj.subComment
                    $0.cell.reviewOptionButton.setTitle(obj.comment, for: .normal)
                    $0.cell.reviewOptionButton.tag = obj.entityID
                    $0.cell.tag = obj.entityID
                    $0.cell.delegate = self
                }
                
                
            })
            self.form.sectionBy(tag: "list Buyer reviews")?.reload()
        }
        
    }
}

extension RaiseConcernController: SingleButtonActionProtocol, BuyerFaultyOrderOptionProtocol {
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
    
    func singleButtonSelected(tag: Int) {
        switch tag {
        case 101:
            print(optionsArray)
            print(self.viewModel.additionalNote.value)
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
            print(str)
        default:
            print("do nothing")
        }
    }
    
    
}
