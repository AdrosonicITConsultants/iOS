//
//  BuyerEnquiryListController.swift
//  CraftExchange
//
//  Created by Preety Singh on 04/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability
import WMSegmentControl

class BuyerEnquiryListController: UIViewController {

    let reuseIdentifier = "BuyerEnquiryCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var getDeliveryTimes: (() -> ())?
    var getCurrencySigns: (() -> ())?
    var allEnquiries: [Enquiry]?
    var ongoingEnquiries: [Int] = []
    var closedEnquiries: [Int] = []
    let realm = try? Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: WMSegment!
    @IBOutlet weak var emptyView: UIImageView!
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDeliveryTimes?()
        getCurrencySigns?()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allEnquiries = []
        definesPresentationContext = false
        self.setupSideMenu(false)
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
        segmentView.bottomBarHeight = 5
        segmentView.type = .normal
        segmentView.selectorType = .bottomBar
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        if self.reachabilityManager?.connection == .unavailable {
        // let realm = try? Realm()
         
         if self.segmentView.selectedSegmentIndex == 0 {
             self.allEnquiries = realm?.objects(Enquiry.self).filter("%K == %@","isOpen",true ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
         }else {
             self.allEnquiries = realm?.objects(Enquiry.self).filter("%K == %@","isOpen",false ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
         }
         
        }else{
            if segmentView.selectedSegmentIndex == 0 {
                allEnquiries = realm?.objects(Enquiry.self).filter("%K IN %@","entityID",ongoingEnquiries ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            }else {
                allEnquiries = realm?.objects(Enquiry.self).filter("%K IN %@","entityID",closedEnquiries ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            }
        }
        
        emptyView.isHidden = allEnquiries?.count == 0 ? false : true
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        viewWillAppear?()
    }
}

extension BuyerEnquiryListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEnquiries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuyerEnquiryCell
        if let obj = allEnquiries?[indexPath.row] {
            cell.configure(obj)
            if segmentView.selectedSegmentIndex == 1 {
                if obj.enquiryStageId == 10 {
                    cell.statusLabel.textColor = UIColor().CEGreen()
                    cell.statusLabel.text = "Enquiry Completed"
                    cell.statusDot.backgroundColor = UIColor().CEGreen()
                }else {
                    cell.statusLabel.textColor = .red
                    cell.statusLabel.text = "Enquiry Closed"
                    cell.statusDot.backgroundColor = .red
                }
                cell.requestMOQLabel.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("*** object ***")
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            if let obj = allEnquiries?[indexPath.row] {
                let vc = EnquiryDetailsService(client: client).createEnquiryDetailScene(forEnquiry: allEnquiries?[indexPath.row], enquiryId: obj.entityID) as! BuyerEnquiryDetailsController
                vc.modalPresentationStyle = .fullScreen
                if segmentView.selectedSegmentIndex == 0 {
                    vc.isClosed = false
                }else {
                    vc.isClosed = true
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return segmentView.selectedSegmentIndex == 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let viewEditAction = UIContextualAction(style: .normal, title:  "Chat".localized) { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            do {
             let client = try SafeClient(wrapping: CraftExchangeClient())
            if let obj = self.allEnquiries?[indexPath.row] {
                let service = ChatListService.init(client: client)
                service.initiateConversation(vc: self, enquiryId: obj.entityID)

            }
                
            }catch {
                print(error.localizedDescription)
            }
            
            success(true)
        
        }
        viewEditAction.image = UIImage.init(named: "chat-icon")
        viewEditAction.backgroundColor = UIColor().CEMagenda()

        return UISwipeActionsConfiguration(actions: [viewEditAction])
    }
    
}
