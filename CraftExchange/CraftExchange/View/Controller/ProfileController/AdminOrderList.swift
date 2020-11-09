//
//  AdminOrderList.swift
//  CraftExchange
//
//  Created by Kiran Songire on 06/11/20.
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

class AdminOrderListViewModel {
}

class AdminOrderList: FormViewController {
    
    var editEnabled = false
    var viewModel = AdminOrderListViewModel()
    var allCountries: Results<Country>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black

        let realm = try! Realm()
        form +++
            Section()
           
            <<< MarketActionsRow() {
                    $0.tag = "Ongoing Orders"
                    $0.cell.backgroundColor = UIColor.black
                    $0.cell.ActionBtn.backgroundColor = UIColor.black
                    $0.cell.ColorLine.backgroundColor = UIColor.blue
                    
                    $0.cell.ActionLabel.text = "Ongoing Orders"
                    $0.cell.LowerActionLabel.text = "87,56,565"
                    $0.cell.ActionImg.isHidden = true
                    $0.cell.height = { 100.0 }
            }
           <<< MarketActionsRow() {
                   $0.tag = "Incomplete & closed"
                   $0.cell.backgroundColor = UIColor.black
                   $0.cell.ActionBtn.backgroundColor = UIColor.black
                   $0.cell.ColorLine.backgroundColor = UIColor.red
                   
                   $0.cell.ActionLabel.text = "Incomplete & closed"
                   $0.cell.LowerActionLabel.text = "87,56,565"
                   $0.cell.ActionImg.isHidden = true
                   $0.cell.height = { 100.0 }
           }
        <<< MarketActionsRow() {
                          $0.tag = "Complete Successfully"
                          $0.cell.backgroundColor = UIColor.black
                          $0.cell.ActionBtn.backgroundColor = UIColor.black
                          $0.cell.ColorLine.backgroundColor = UIColor.green
                          
                          $0.cell.ActionLabel.text = "Complete Successfully"
                          $0.cell.LowerActionLabel.text = "87,56,565"
                          $0.cell.ActionImg.isHidden = true
                          $0.cell.height = { 100.0 }
                  }
    
    
    
}
}
