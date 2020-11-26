//
//  AdminEscalationController.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm

enum EscalationCat {
    case Updates
    case Chat
    case Payment
    case FaultyOrder
}

class AdminEscalationController: UIViewController {
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var totalEscalationCountLbl: UILabel!
    @IBOutlet weak var escalationCountLbl: UILabel!
    @IBOutlet weak var escalationSearchBar: UISearchBar!
    @IBOutlet weak var escalationSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var catType: EscalationCat?
    
    var reusableIdentifier = "AdminEscalationCell"
    var viewWillAppear: (()->())?
    var reachedLimit = false
    var allEscalations: Results<AdminEscalation>?
    var pageNo = 1
    var eqArray: [Int] = []
    
    let realm = try? Realm()
    
    var showUser: ((_ enquiryId: Int,_ isArtisan: Bool)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reusableIdentifier, bundle: nil), forCellReuseIdentifier: reusableIdentifier)
        tableView.separatorStyle = .none
        let app = UIApplication.shared.delegate as? AppDelegate
        totalEscalationCountLbl.text = "\(app?.countData?.escaltions ?? 0)"
        escalationSearchBar.returnKeyType = .search
        escalationSearchBar.delegate = self
        escalationSearchBar.searchTextField.textColor = .white
        escalationSegmentControl.setBlackControl()
        catType = .Updates
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
    }
    
    @IBAction func segmentControlDidChanged(_ sender: Any) {
        pageNo = 1
        reachedLimit = false
        escalationSearchBar.resignFirstResponder()
        eqArray = []
        switch escalationSegmentControl.selectedSegmentIndex {
        case 0:
            catType = .Updates
        case 1:
            catType = .Chat
        case 2:
            catType = .Payment
        case 3:
            catType = .FaultyOrder
        default:
            catType = .Updates
        }
        viewWillAppear?()
    }
}

extension AdminEscalationController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEscalations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) as! AdminEscalationCell
        if let obj = allEscalations?[indexPath.row] {
            cell.titleLabel1.text = obj.enquiryCode ?? ""
            cell.titleLabel3.text = obj.date?.ttceISOString(isoDate: obj.date ?? obj.lastUpdated ?? Date()) ?? ""
            if obj.raisedBy == 1 {
                cell.titleLabel4.addImageWith(name: "artisan icon", behindText: true)
            }else if obj.raisedBy == 2 {
                cell.titleLabel4.addImageWith(name: "buyer icon", behindText: true)
            }else {
               cell.titleLabel4.addImageWith(name: "Icon metro-flag", behindText: true)
            }
            switch catType {
            case .Updates:
                cell.titleLabel2.text = obj.stage ?? ""
            case .Chat:
                cell.titleLabel2.text = obj.concern ?? ""
            case .Payment:
                cell.titleLabel2.text = obj.concern ?? ""
            case .FaultyOrder:
                cell.titleLabel2.text = obj.category ?? ""
            default:
                print("do nothing")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.allEscalations?.count ?? 0 > 0 && self.reachedLimit == false {
            let lastElement = (allEscalations?.count ?? 0) - 1
            if indexPath.row == lastElement {
                pageNo += 1
                self.viewWillAppear?()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed(reusableIdentifier, owner:
        self, options: nil)?.first as! AdminEscalationCell
        header.titleLabel1.text = "Enquiry Id"
        switch catType {
        case .Updates:
            header.titleLabel2.text = "Stage"
        case .FaultyOrder:
            header.titleLabel2.text = "Category"
        default:
            header.titleLabel2.text = "Concern"
        }
        
        header.titleLabel3.text = "Date raised"
        header.titleLabel4.text = "Raised by"
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch catType {
        case .Updates:
            self.showUpdateAction(index: indexPath.row)
        case .Chat:
            self.showChatAction(index: indexPath.row)
        case .Payment:
            self.showPaymentAction(index: indexPath.row)
        case .FaultyOrder:
            self.showDefaultOrderAction(index: indexPath.row)
        default:
            print("do nothing")
        }
    }
    
    func showUpdateAction(index: Int) {
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let options = ["View Artisan Details", "View Buyer Details"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                if let obj = self.allEscalations?[index] {
                    switch option {
                    case "View Artisan Details":
                        self.showUser?(obj.enquiryId,true)
                    case "View Buyer Details":
                        self.showUser?(obj.enquiryId,false)
                    default:
                        print("do nothing")
                    }
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showChatAction(index: Int) {
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let options = ["View Artisan Details", "View Buyer Details", "View Chat"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                if let obj = self.allEscalations?[index] {
                    switch option {
                    case "View Artisan Details":
                        self.showUser?(obj.enquiryId,true)
                    case "View Buyer Details":
                        self.showUser?(obj.enquiryId,false)
                    case "View Chat":
                        print("do nothing")
                    default:
                        print("do nothing")
                    }
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPaymentAction(index: Int) {
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let options = ["View Artisan Details", "View Buyer Details", "View Chat", "View Transactions"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                if let obj = self.allEscalations?[index] {
                    switch option {
                    case "View Artisan Details":
                        self.showUser?(obj.enquiryId,true)
                    case "View Buyer Details":
                        self.showUser?(obj.enquiryId,false)
                    case "View Chat":
                        print("do nothing")
                    case "View Transactions":
                        print("do nothing")
                    default:
                        print("do nothing")
                    }
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDefaultOrderAction(index: Int) {
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let options = ["View Chat", "Mark Resolved", "Generate new enquiry & redirect"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                switch option {
                case "View Artisan Details":
                    print("do nothing")
                case "Mark Resolved":
                    print("do nothing")
                case "Generate new enquiry & redirect":
                    print("do nothing")
                default:
                    print("do nothing")
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension AdminEscalationController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        escalationSegmentControl.sendActions(for: .valueChanged)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

