//
//  UploadProductController.swift
//  CraftExchange
//
//  Created by Preety Singh on 29/07/20.
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

enum NewProductState {
    case addPhotos
    case addGeneralDetails
    case selectWeaveType
    case selectWarpWeftYarn
    case reedCount
    case dimensions
    case washCare
    case availability
    case weight
    case gsm
    case addDescription
}

class UploadProductViewModel {
    
}

class UploadProductController: FormViewController {
    var currentState: NewProductState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        form +++
            Section()
            <<< LabelRow() {
                $0.title = User.loggedIn()?.email ?? ""
                $0.cellStyle = .default
                $0.cell.height = { 40.0 }
                $0.cell.imageView?.image = UIImage(named: "emailIcon")
                $0.cell.imageView?.tintColor = .darkGray
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .darkGray
            })
            <<< LabelRow() { row in
                row.cell.height = { 300.0 }
            }
    }
    
    func expandSection() {
        
    }
}

