//
//  OrderListController.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/10/20.
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

class OrderListController: UIViewController {

    let reuseIdentifier = "BuyerEnquiryCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var getDeliveryTimes: (() -> ())?
    var getCurrencySigns: (() -> ())?
    var getReviewAndRatingData: (() -> ())?
    var allOrders: [Order]?
    var ongoingOrders: [Int] = []
    var closedOrders: [Int] = []
    let realm = try? Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: WMSegment!
    @IBOutlet weak var emptyView: UIImageView!
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDeliveryTimes?()
        getCurrencySigns?()
        getReviewAndRatingData?()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allOrders = []
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
        if User.loggedIn()?.refRoleId == "1" {
            self.emptyView.image = UIImage.init(named: "no-order-artisan")
        }else {
            self.emptyView.image = UIImage.init(named: "no-order-buyer")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
        segmentView.buttonTitles = "Ongoing, Completed".localized
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
            self.allOrders = realm?.objects(Order.self).filter("%K == %@","isOpen",true ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }else {
            self.allOrders = realm?.objects(Order.self).filter("%K == %@","isOpen",false ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }
        
        }else{
        
        if segmentView.selectedSegmentIndex == 0 {
            allOrders = realm?.objects(Order.self).filter("%K IN %@","entityID",ongoingOrders ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }else {
            allOrders = realm?.objects(Order.self).filter("%K IN %@","entityID",closedOrders ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }
        }
        emptyView.isHidden = allOrders?.count == 0 ? false : true
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        self.allOrders?.removeAll()
        viewWillAppear?()
    }
}

extension OrderListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allOrders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuyerEnquiryCell
        if let obj = allOrders?[indexPath.row] {
            cell.configure(obj)
            if segmentView.selectedSegmentIndex == 1 {
                if obj.enquiryStageId == 10 {
                    cell.statusLabel.textColor = UIColor().CEGreen()
                    cell.statusLabel.text = "Order Completed"
                    cell.statusDot.backgroundColor = UIColor().CEGreen()
                }else {
                    cell.statusLabel.textColor = .red
                    cell.statusLabel.text = "Order Closed"
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
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            if let obj = allOrders?[indexPath.row] {
                let vc = OrderDetailsService(client: client).createOrderDetailScene(forOrder: allOrders?[indexPath.row], enquiryId: obj.entityID) as! OrderDetailController
                vc.modalPresentationStyle = .fullScreen
                if segmentView.selectedSegmentIndex == 0 {
                    vc.isClosed = false
                }else {
                    vc.isClosed = true
                }
                self.navigationController?.pushViewController(vc, animated: false)
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
        let viewEditAction = UIContextualAction(style: .normal, title:  "Chat".localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            do {
             let client = try SafeClient(wrapping: CraftExchangeClient())
            if let obj = self.allOrders?[indexPath.row] {
                let service = ChatListService.init(client: client)
                service.initiateConversation(vc: self, enquiryId: obj.entityID)
            }
            }catch {
                print(error.localizedDescription)
            }
            
            success(true)
            
        })
        viewEditAction.image = UIImage.init(named: "chat-icon")
        viewEditAction.backgroundColor = UIColor().CEMagenda()

        return UISwipeActionsConfiguration(actions: [viewEditAction])
    }
}

