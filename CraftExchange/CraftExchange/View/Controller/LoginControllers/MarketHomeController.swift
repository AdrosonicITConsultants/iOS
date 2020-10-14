//
//  MarketHomeController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 09/10/20.
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
import ViewRow
import WebKit

class MarketHomeController: FormViewController {
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        form
            +++ Section()
            <<< AdminHomeHeaderRow()
                {
                    $0.tag = "HorizonatalAdmin0"
                    $0.cell.backgroundColor = UIColor.black
                    $0.cell.Logo.image = UIImage(named: "AppIcon")
                    $0.cell.height = { 100.0 }
            }
            <<< AdminLabelRow(){
                $0.tag = "AdminLabelRow-1"
                $0.cell.AdminLabel.text = "Report"
                $0.cell.height = { 40.0 }
            }
            <<< AdminCardsRow () {
                $0.tag = "Myrow"
                $0.cell.height = { 200.0 }
            }
            
            <<< AdminLabelRow(){
                $0.tag = "AdminLabelRow-2"
                $0.cell.AdminLabel.text = "Quick Actions"
                $0.cell.height = { 40.0 }
            }
            
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin1"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.red
                $0.cell.ActionLabel.text = "Fault and Escalations 3454"
                $0.cell.ActionImg.image = UIImage(named: "AppIcon")
                $0.cell.height = { 80.0 }
            }
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin2"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.systemYellow
                $0.cell.ActionLabel.text = "Add a Product to Antaran Co Design"
                $0.cell.ActionImg.image = UIImage(named: "AppIcon")
                $0.cell.height = { 80.0 }
            }
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin3"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.gray
                $0.cell.ActionLabel.text = "Redirect Custom enquiries awaiting MOQs"
                $0.cell.ActionImg.image = UIImage(named: "Groupicon")
                $0.cell.height = { 80.0 }
            }
            <<< AdminHomeBottomRow() {
                $0.cell.height = { 280.0 }
        }
        
    }
}
