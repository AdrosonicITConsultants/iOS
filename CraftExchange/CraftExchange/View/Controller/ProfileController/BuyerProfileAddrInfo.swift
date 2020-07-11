//
//  BuyerProfileAddrInfo.swift
//  CraftExchange
//
//  Created by Preety Singh on 10/07/20.
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

class BuyerProfileAddrInfo: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        self.form +++
          Section()
            <<< LabelRow() {
                $0.cell.height = { 80.0 }
                $0.title = "Delivery Address".localized
            }.cellUpdate({ (cell, row) in
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 2 {
                        addressString = address.addressString
                    }
                })
                cell.detailTextLabel?.text = addressString
                cell.detailTextLabel?.numberOfLines = 10
                cell.detailTextLabel?.font = .systemFont(ofSize: 10)
            })
            <<< LabelRow() { row in
                row.cell.height = { 400.0 }
            }
    }
}
