//
//  EnquiryArtisanDetailsController.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/09/20.
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
import ImageRow

class EnquiryArtisanDetailsController: FormViewController {
    
    var enquiryObject: Enquiry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        form +++
        Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                $0.cell.isUserInteractionEnabled = false
                $0.cell.actionButton.isUserInteractionEnabled = false
            }
            <<< LabelRow() {
                $0.title = enquiryObject?.brandName
            }
            <<< LabelRow() {
                $0.title = enquiryObject?.productName
            }
            <<< LabelRow() {
                $0.title = enquiryObject?.firstName
            }
            <<< LabelRow() {
                $0.title = enquiryObject?.eqDescription
            }
            <<< LabelRow() {
                $0.title = "Specialist in"
                var lbl = ""
                enquiryObject?.productCategories .forEach({ (catId) in
                    if catId == enquiryObject?.productCategories.last {
                        lbl.append("\(ProductCategory.getProductCat(catId: catId)?.prodCatDescription ?? "")")
                    }else {
                        lbl.append("\(ProductCategory.getProductCat(catId: catId)?.prodCatDescription ?? ""), ")
                    }
                })
                $0.value = lbl
            }
    }
}
