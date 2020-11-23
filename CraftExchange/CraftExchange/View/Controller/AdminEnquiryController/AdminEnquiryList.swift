//
//  AdminEnquiryList.swift
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

class AdminEnquiryListViewModel {
}

class AdminEnquiryList: FormViewController {
    
    var editEnabled = false
    var viewModel = AdminEnquiryListViewModel()
    var allCountries: Results<Country>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView?.backgroundColor = .black

        form +++
            Section()
            <<< MarketActionsRow() {
                $0.tag = "Ongoing Enquiries"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.backgroundGradientView.backgroundColor = UIColor.black
                $0.cell.ActionLabel.text = "Ongoing Enquiries"
                $0.cell.LowerActionLabel.text = "87,56,565"
                $0.cell.ColorLine.backgroundColor = UIColor.blue
                $0.cell.ActionImg.isHidden = true
                $0.cell.height = { 100.0 }
            }.cellUpdate({ (cell, row) in
                let app = UIApplication.shared.delegate as? AppDelegate
                cell.LowerActionLabel.text = "\(app?.countData?.ongoingEnquiries ?? 0)"
            }).onCellSelection({ (cell, row) in
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let vc = AdminEnquiryListService(client: client).createScene()
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }catch {
                    print(error.localizedDescription)
                }
            })
            
            <<< MarketActionsRow() {
                $0.tag = "Incomplete & closed"
                $0.cell.backgroundColor = UIColor.black
                $0.cell.backgroundGradientView.backgroundColor = UIColor.black
                $0.cell.ColorLine.backgroundColor = UIColor.red
                
                $0.cell.ActionLabel.text = "Incomplete & closed"
                $0.cell.LowerActionLabel.text = "87,56,565"
                $0.cell.ActionImg.isHidden = true
                $0.cell.height = { 100.0 }
        }.cellUpdate({ (cell, row) in
            let app = UIApplication.shared.delegate as? AppDelegate
            cell.LowerActionLabel.text = "\(app?.countData?.incompleteAndClosedEnquiries ?? 0)"
        })
        
            <<< AdminHomeBottomRow() {
                $0.tag = "Converted Enquiries"
                $0.cell.height = { 142.0 }
                $0.cell.OngoingBtn.backgroundColor = UIColor.purple
                $0.cell.ClosedBtn.backgroundColor = UIColor.purple
                $0.cell.topLabel2.text = "Awaiting response over MOQ from buyer"
                $0.cell.BottomLabel2.text = "897835"
                $0.cell.topLabel1.text = "Enquiries Converted"
                $0.cell.BottomLabel1.text = "897835"
        }.cellUpdate({ (cell, row) in
            let app = UIApplication.shared.delegate as? AppDelegate
            cell.BottomLabel1.text = "\(app?.countData?.enquiriesConverted ?? 0)"
            cell.BottomLabel2.text = "\(app?.countData?.awaitingMoqResponse ?? 0)"
           
        })
        
    }
    
    
    
    
}

