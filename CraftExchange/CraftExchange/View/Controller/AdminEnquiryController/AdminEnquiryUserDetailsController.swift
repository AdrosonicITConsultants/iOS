//
//  AdminEnquiryUserDetailsController.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/11/20.
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

class AdminEnquiryUserDetailsController: FormViewController {
    
    var isArtisan = false
    var primaryEmail: String?
    var primaryContact: String?
    var secondaryContact: String?
    var pocFirstName: String?
    var pocLastName: String?
    var pocEmail: String?
    var pocContact: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        form +++
        Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                $0.cell.isUserInteractionEnabled = false
                $0.cell.actionButton.isUserInteractionEnabled = false
                if isArtisan {
                    $0.cell.actionButton.setImage(UIImage.init(named: "artisan screen logo"), for: .normal)
                }else {
                    $0.cell.actionButton.setImage(UIImage.init(named: "buyer screen logo"), for: .normal)
                }
                $0.cell.actionButton.layer.cornerRadius = 0
                $0.cell.actionButton.layer.borderWidth = 0
                $0.cell.contentView.backgroundColor = .black
            }
            <<< LabelRow() {
                $0.title = isArtisan == true ? "Artisan Entrepreneur" : "Buyer Details"
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() {
                $0.title = primaryEmail
                $0.cellStyle = .default
                $0.cell.height = { 40.0 }
                $0.cell.imageView?.image = UIImage(named: "emailIcon")
                $0.cell.imageView?.tintColor = .lightGray
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() { row in
                row.title = primaryContact
                row.cell.imageView?.image = UIImage(named: "phoneIcon")
                row.cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
                row.cell.height = { 40.0 }
                row.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() { row in
                row.title = secondaryContact
                row.cell.imageView?.image = UIImage(named: "phoneIcon")
                row.cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
                row.cell.height = { 40.0 }
                if isArtisan {
                    row.hidden = true
                }else {
                    if let text = secondaryContact, text.isNotBlank {
                        row.hidden = false
                    }else {
                        row.hidden = true
                    }
                }
                row.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() {
                $0.title = "Point of Contact"
                $0.hidden = isArtisan == true ? true : false
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() {
                $0.title = "\(pocFirstName ?? "NA") \(pocLastName ?? "")"
                $0.hidden = isArtisan == true ? true : false
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() {
                $0.title = pocContact ?? "NA"
                $0.hidden = isArtisan == true ? true : false
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
            <<< LabelRow() {
                $0.title = pocEmail ?? "NA"
                $0.hidden = isArtisan == true ? true : false
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = .white
            })
    }
}
