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
    var allCountries: Results<Country>?
    var isEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditing), name: Notification.Name("EnableEditNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableEditing), name: Notification.Name("DisableEditNotification"), object: nil)
        let parentVC = self.parent as! BuyerProfileController
        let realm = try! Realm()
        allCountries = realm.objects(Country.self).sorted(byKeyPath: "entityID")
        
        self.form +++
          Section()
            <<< LabelRow() {
                $0.cell.height = { 80.0 }
                $0.title = "Delivery Address".localized
            }.cellUpdate({ (cell, row) in
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 2 && address.pincode?.isNotBlank ?? false && address.line1?.isNotBlank ?? false{
                        addressString = address.addressString
                    }else if address.addressType?.entityID == 1 {
                        addressString = address.addressString
                    }
                })
                cell.detailTextLabel?.text = addressString
                cell.detailTextLabel?.numberOfLines = 10
                cell.detailTextLabel?.font = .systemFont(ofSize: 10)
            })
            +++ Section() {
                $0.tag = "EditAddressSection"
                $0.hidden = true
            }
            <<< TextRow() {
                $0.tag = "AddressEditRow1"
                $0.title = "Address Line 1".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.line1 ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                parentVC.viewModel.addr1.value = $0.cell.textField.text
                parentVC.viewModel.addr1.bidirectionalBind(to: $0.cell.textField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.addr1.value = cell.textField.text
                })
            <<< TextRow() {
            $0.tag = "AddressEditRow2"
            $0.title = "Address Line 2".localized
            var addressString = ""
            User.loggedIn()?.addressList .forEach({ (address) in
                if address.addressType?.entityID == 1 {
                    addressString = address.line2 ?? ""
                }
            })
            $0.cell.textField.text = addressString
            parentVC.viewModel.addr2.value = $0.cell.textField.text
            parentVC.viewModel.addr2.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                parentVC.viewModel.addr2.value = cell.textField.text
            })
            <<< TextRow() {
            $0.tag = "AddressEditRow3"
            $0.title = "Street".localized
            var addressString = ""
            User.loggedIn()?.addressList .forEach({ (address) in
                if address.addressType?.entityID == 1 {
                    addressString = address.street ?? ""
                }
            })
            $0.cell.textField.text = addressString
            parentVC.viewModel.street.value = $0.cell.textField.text
            parentVC.viewModel.street.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                parentVC.viewModel.street.value = cell.textField.text
            })
            <<< TextRow() {
                $0.tag = "AddressEditRow4"
                $0.title = "District".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.district ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                parentVC.viewModel.district.value = $0.cell.textField.text
                parentVC.viewModel.district.bidirectionalBind(to: $0.cell.textField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.district.value = cell.textField.text
                })
            <<< TextRow() {
                $0.tag = "AddressEditRow5"
                $0.title = "City".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.city ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                parentVC.viewModel.city.value = $0.cell.textField.text
                parentVC.viewModel.city.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                parentVC.viewModel.city.value = cell.textField.text
            })
            <<< TextRow() {
                $0.tag = "AddressEditRow6"
                $0.title = "State".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.state ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                parentVC.viewModel.state.value = $0.cell.textField.text
                parentVC.viewModel.state.bidirectionalBind(to: $0.cell.textField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    parentVC.viewModel.state.value = cell.textField.text
                })
            <<< TextRow() {
                $0.tag = "AddressEditRow7"
                $0.title = "Pincode".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.pincode ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                parentVC.viewModel.pincode.value = $0.cell.textField.text
                parentVC.viewModel.pincode.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                parentVC.viewModel.pincode.value = cell.textField.text
            })
            <<< ActionSheetRow<String>() { row in
                row.tag = "AddressEditRow8"
                row.title = "Country"
                row.cell.height = { 80.0 }
                row.options = allCountries?.compactMap { $0.name }
            }.cellUpdate({ (cell, row) in
                row.cell.textLabel?.text = "Country".localized
                parentVC.viewModel.country.value = row.value
            })
            <<< LabelRow() { row in
                row.cell.height = { 400.0 }
            }
    }
    
    @objc func enableEditing() {
        self.view.backgroundColor = .lightGray
        let secRow = self.form.sectionBy(tag: "EditAddressSection")
        isEditable = true
        secRow?.hidden = false
        secRow?.evaluateHidden()
    }
    
    @objc func disableEditing() {
        let secRow = self.form.sectionBy(tag: "EditAddressSection")
        isEditable = false
        secRow?.hidden = true
        secRow?.evaluateHidden()
    }
}
