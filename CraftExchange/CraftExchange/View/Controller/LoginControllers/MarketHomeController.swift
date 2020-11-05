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
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        form
            +++ Section()
            
            <<< AdminHomeHeaderRow() {
                $0.tag = "HorizonatalAdmin0"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.Logo.image = UIImage(named: "cx")
                $0.cell.delegate = self
                $0.cell.tag = 110
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
               $0.cell.delegate = self
                $0.cell.tag = 109
                $0.cell.ActionLabel.text = "Fault and Escalations"
                $0.cell.LowerActionLabel.text = "3454"
                $0.cell.ActionImg.image = UIImage(named: "Icon ionic-ios-alert (1)")
                $0.cell.height = { 80.0 }
            }
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin2"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.systemYellow
                $0.cell.ActionLabel.text = "Add a Product"
                $0.cell.LowerActionLabel.text = " to Antaran Co Design"

                $0.cell.ActionImg.image = UIImage(named: "Groupicon")
                $0.cell.height = { 80.0 }
            }
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin3"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.gray
                $0.cell.ActionLabel.text = "Redirect Custom enquiries"
                $0.cell.LowerActionLabel.text = "awaiting MOQs"
                $0.cell.ActionImg.image = UIImage(named: "Icon awesome-route")
                $0.cell.height = { 80.0 }
            }
            <<< AdminHomeBottomRow() {
                $0.cell.height = { 142.0 }
            }
            <<< ButtonRow() {
                $0.title = "Logout"
                $0.cell.height = { 40.0 }
            }.cellUpdate({ (cell, row) in
                cell.backgroundColor = .black
                cell.tintColor = .white
            }).onCellSelection({ (cell, row) in
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.tabbar = nil
                appDelegate?.artisanTabbar = nil
                KeychainManager.standard.deleteAll()
                UIApplication.shared.unregisterForRemoteNotifications()
                UIApplication.shared.applicationIconBadgeNumber = 0
                self.showLoading()
                guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
                    _ = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
                    return
                }
                let controller = LoginUserService(client: client).createScene()
                controller.modalPresentationStyle = .fullScreen
                self.dismiss(animated: true) {
                    self.present(controller, animated: true, completion: nil)
                }
            })
    }
}

extension MarketHomeController: MarketActionsProtocol, NotifyButtonProtocol{
    func NotifyBtnSelected(tag: Int){
        switch tag{
            case 110:
                let storyboard = UIStoryboard(name: "AdminNotification", bundle: nil)
                let vc1 = storyboard.instantiateViewController(withIdentifier: "AdminNotificationController") as! AdminNotificationController
                vc1.modalPresentationStyle = .fullScreen
                self.present(vc1, animated: true, completion: nil)
                
            default:
                print("Notify Not WORKING")
            }
    }
    func ArrowBtnSelected(tag: Int) {
    switch tag{
    case 109:
        let storyboard = UIStoryboard(name: "AdminUserDatabase", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "AdminUserController") as! AdminUserController
        vc1.modalPresentationStyle = .fullScreen
        self.present(vc1, animated: true, completion: nil)

        self.navigationController?.pushViewController(vc1, animated: true)
        print("DbBtnSelected")
        
    default:
        print("DbBtnSelected Not WORKING")
    }
}
}
