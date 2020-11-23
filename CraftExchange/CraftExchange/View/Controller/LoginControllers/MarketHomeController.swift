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
    var chatCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        MarketingTeammateService().getEnquiryAndOrderCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        refreshCountForTag()
        form
            +++ Section()

            <<< AdminLabelRow(){
                $0.tag = "AdminLabelRow-1"
                $0.cell.AdminLabel.text = "Report"
                $0.cell.height = { 40.0 }
            }
            <<< AdminCardsRow () {
                $0.tag = "Myrow"
                $0.cell.height = { 200.0 }
                $0.cell.tag = 101
                $0.cell.delegate = self
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
                $0.cell.LowerActionLabel.text = ""
                $0.cell.ColorLine.isHidden = true
                $0.cell.ActionImg.image = UIImage(named: "Icon ionic-ios-alert (1)")
                $0.cell.height = { 80.0 }
            }.cellUpdate({ (cell, row) in
                let app = UIApplication.shared.delegate as? AppDelegate
                cell.LowerActionLabel.text = "\(app?.countData?.escaltions ?? 0)"
            })
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin2"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.systemYellow
                $0.cell.ActionLabel.text = "Add a Product"
                $0.cell.ColorLine.isHidden = true
                $0.cell.LowerActionLabel.text = " to Antaran Co Design"
                $0.cell.ActionImg.image = UIImage(named: "Groupicon")
                $0.cell.height = { 80.0 }
            }
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin3"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.ActionBtn.backgroundColor = UIColor.gray
                $0.cell.ActionLabel.text = "Redirect Custom enquiries"
                $0.cell.ColorLine.isHidden = true
                $0.cell.LowerActionLabel.text = "awaiting MOQs"
                $0.cell.ActionImg.image = UIImage(named: "Icon awesome-route")
                $0.cell.height = { 80.0 }
            }
            <<< AdminHomeBottomRow() {
//                $0.tag = "Converted Enquiries"
//                $0.cell.height = { 142.0 }
//                $0.cell.OngoingBtn.backgroundColor = #colorLiteral(red: 0.5953189731, green: 0.5651128292, blue: 0.992895782, alpha: 1)
//                $0.cell.ClosedBtn.backgroundColor = #colorLiteral(red: 0, green: 0.9860576987, blue: 0.3044478297, alpha: 1)
//                $0.cell.topLabel2.text = "Ongoing Enquiries"
//                $0.cell.BottomLabel2.text = "897835"
//                $0.cell.topLabel1.text = "Closed Enquiries"
//                $0.cell.BottomLabel1.text = "897835"
//            }.cellUpdate({ (cell, row) in
//                let app = UIApplication.shared.delegate as? AppDelegate
//                cell.BottomLabel1.text = "\(app?.countData?.ongoingEnquiries ?? 0)"
//                cell.BottomLabel2.text = "\(app?.countData?.incompleteAndClosedEnquiries ?? 0)"
//
//            })
    
                $0.cell.height = { 142.0 }
            }.cellUpdate({ (cell, row) in
                let app = UIApplication.shared.delegate as? AppDelegate
//                AdminHomeBottom.botto
//                BottomLabel1.text = "\(app?.countData?.escaltions ?? 0)"
//                BottomLabel2.text = "\(app?.countData?.escaltions ?? 0)"
            })
            
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

extension MarketHomeController: MarketActionsProtocol, ArrowBtnProtocol {
    func ArrowSelected(tag: Int) {
        switch tag {
            case 101:
                let dashboardStoryboard = UIStoryboard.init(name: "MyDashboard", bundle: Bundle.main)
                let vc = dashboardStoryboard.instantiateViewController(withIdentifier: "DashboardController") as! DashboardController
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print("..")
        }
    }

    func refreshCountForTag(){
        self.form.allSections.first?.reload()
        let row = self.form.rowBy(tag: "HorizonatalAdmin1")
        row?.updateCell()
    }

    func ArrowBtnSelected(tag: Int) {
        
    }
}
