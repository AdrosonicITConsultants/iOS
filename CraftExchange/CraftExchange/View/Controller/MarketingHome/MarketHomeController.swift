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

class MarketHomeViewModel {
    var artisanBrandUrl = Observable<String?>("")
    var artisanName = Observable<String?>("")
    var viewDidLoad: (() -> Void)?
    var viewWillAppear: (() -> Void)?
}

class MarketHomeController: FormViewController {
    
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var dataSource: [ProductCategory]?
    lazy var viewModel = MarketHomeViewModel()
    var reachabilityManager = try? Reachability()
    var chatCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad?()
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        viewWillAppear?()
        refreshCountForTag()
        let rightBarButtomItem = UIBarButtonItem(customView: self.notificationBarButton())
        navigationItem.rightBarButtonItems = [rightBarButtomItem]
        
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
                let gradient = CAGradientLayer()
                gradient.frame = CGRect(x: 0, y: 0, width: $0.cell.B1.bounds.width, height: $0.cell.B1.bounds.height)
                gradient.startPoint = CGPoint(x:0, y:0)
                gradient.endPoint = CGPoint(x:1, y:1)
                gradient.colors = [UIColor(red: 0.0863, green: 0.3098, blue: 0.8784, alpha: 1.0).cgColor, UIColor(red: 0.5529, green: 0.6549, blue: 0.9098, alpha: 1.0).cgColor]
                gradient.cornerRadius = 10
                $0.cell.B1.layer.addSublayer(gradient)
                
                
                let gradient1 = CAGradientLayer()
                gradient1.frame = CGRect(x: 0, y: 0, width: $0.cell.b2.bounds.width, height: $0.cell.b2.bounds.height)
                gradient1.startPoint = CGPoint(x:0, y:0)
                gradient1.endPoint = CGPoint(x:1, y:1)
                gradient1.colors = [UIColor(red: 0.898, green: 0.0431, blue: 0.698, alpha: 1.0).cgColor,UIColor(red: 0.8275, green: 0.0431, blue: 0.898, alpha: 1.0).cgColor, UIColor(red: 0.0863, green: 0.3098, blue: 0.8784, alpha: 1.0).cgColor]
                gradient1.cornerRadius = 10
                $0.cell.b2.layer.addSublayer(gradient1)
                
                let gradient2 = CAGradientLayer()
                gradient2.frame = CGRect(x: 0, y: 0, width: $0.cell.b3.bounds.width, height: $0.cell.b3.bounds.height)
                gradient2.startPoint = CGPoint(x:0, y:0)
                gradient2.endPoint = CGPoint(x:1, y:1)
                gradient2.colors = [UIColor(red: 0.2471, green: 0.749, blue: 0.1686, alpha: 1.0).cgColor, UIColor(red: 0.0549, green: 0.2902, blue: 0.4314, alpha: 1.0).cgColor]
                gradient2.cornerRadius = 10
                $0.cell.b3.layer.addSublayer(gradient2)
                
            }
            <<< AdminLabelRow(){
                $0.tag = "AdminLabelRow-2"
                $0.cell.AdminLabel.text = "Quick Actions"
                $0.cell.height = { 40.0 }
            }
            
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin1"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.backgroundGradientView.backgroundColor = UIColor.red
                let gradient = CAGradientLayer()
                gradient.frame = CGRect(x: 0, y: 0, width: $0.cell.backgroundGradientView.bounds.width, height: 60)
                gradient.startPoint = CGPoint(x:0.0, y:1)
                gradient.endPoint = CGPoint(x:1.0, y:1)
                gradient.colors = [UIColor.red.cgColor,UIColor(red: 0.6275, green: 0.1059, blue: 0.1765, alpha: 1.0).cgColor]
                gradient.cornerRadius = 10
                $0.cell.backgroundGradientView.layer.addSublayer(gradient)
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
            }).onCellSelection({ (cell, row) in
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let vc = AdminEscalationService(client: client).createScene() as! AdminEscalationController
                    vc.modalPresentationStyle = .fullScreen
                    vc.catType = .Updates
                    self.navigationController?.pushViewController(vc, animated: true)
                }catch {
                    print(error.localizedDescription)
                }
            })
                
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin2"
                $0.cell.backgroundColor = UIColor.black
                let gradient = CAGradientLayer()
                gradient.frame = CGRect(x: 0, y: 0, width: $0.cell.backgroundGradientView.bounds.width, height: 60)
                gradient.startPoint = CGPoint(x:0.0, y:1)
                gradient.endPoint = CGPoint(x:1.0, y:1)
                gradient.colors = [UIColor.yellow.cgColor, UIColor(red: 0.5961, green: 0.6275, blue: 0, alpha: 1.0).cgColor]
                gradient.cornerRadius = 10
                $0.cell.backgroundGradientView.layer.addSublayer(gradient)
                $0.cell.ActionLabel.text = "Add a Product"
                $0.cell.ColorLine.isHidden = true
                $0.cell.LowerActionLabel.text = " to Antaran Co Design"
                $0.cell.ActionImg.image = UIImage(named: "Groupicon")
                $0.cell.height = { 80.0 }
            }.onCellSelection({ (cell, row) in
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let vc = UploadProductService(client: client).createScene(productObject: nil)
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }catch {
                    print(error.localizedDescription)
                }
            })
            <<< MarketActionsRow() {
                $0.tag = "HorizonatalAdmin3"
                $0.cell.backgroundColor = UIColor.black
                let gradient = CAGradientLayer()
                gradient.frame = CGRect(x: 0, y: 0, width: $0.cell.backgroundGradientView.bounds.width, height: 60)
                gradient.startPoint = CGPoint(x:0.0, y:1)
                gradient.endPoint = CGPoint(x:1.0, y:1)
                gradient.colors = [UIColor.lightGray.cgColor, UIColor(red: 0.3176, green: 0.3176, blue: 0.302, alpha: 1.0).cgColor]
                gradient.cornerRadius = 10
                $0.cell.backgroundGradientView.layer.addSublayer(gradient)
                $0.cell.ActionLabel.text = "Redirect Custom enquiries"
                $0.cell.ColorLine.isHidden = true
                $0.cell.LowerActionLabel.text = "awaiting MOQs"
                $0.cell.ActionImg.image = UIImage(named: "Icon awesome-route")
                $0.cell.height = { 80.0 }
            }.onCellSelection({ (cell, row) in
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let vc = AdminRedirectEnquiryService(client: client).createScene()
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }catch {
                    print(error.localizedDescription)
                }
            })
            <<< AdminHomeBottomRow() {
                $0.tag = "AdminHomeBottomRow"
                $0.cell.height = { 142.0 }
                $0.cell.OngoingBtn.backgroundColor = UIColor(red: 0.051, green: 0.1882, blue: 0.6471, alpha: 1.0)
                $0.cell.ClosedBtn.backgroundColor = UIColor(red: 0.3804, green: 0.6627, blue: 0.4314, alpha: 1.0)
            }.cellUpdate({ (cell, row) in
                let app = UIApplication.shared.delegate as? AppDelegate
                cell.BottomLabel1.text = "\(app?.countData?.ongoingEnquiries ?? 0)"
                cell.BottomLabel2.text = "\(app?.countData?.incompleteAndClosedEnquiries ?? 0)"
            })
            
            <<< ButtonRow() {
                $0.title = "Logout"
                $0.cell.height = { 40.0 }
            }.cellUpdate({ (cell, row) in
                cell.backgroundColor = .black
                cell.tintColor = .white
            }).onCellSelection({ (cell, row) in
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.marketingTabbar = nil
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
    func ArrowBtnSelected(tag: Int) {
        
    }
    
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
        let row2 = self.form.rowBy(tag: "AdminHomeBottomRow")
        row2?.updateCell()
    }
}
