//
//  NotificationController.swift
//  CraftExchange
//
//  Created by Kalyan on 02/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class NotificationController: UIViewController {
    var allNotifications: [Notifications]?
    var reachabilityManager = try? Reachability()
    var markasRead: ((_ notificationId: Int, _ index: Int) -> ())?
    var markAsReadAllActions: (() -> ())?
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var notificationCount: Int = 0
    let realm = try? Realm()
    let reuseIdentifier = "NotificationCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var markAllAsRead: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OfflineRequestManager.defaultManager.delegate = self
       
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allNotifications = realm?.objects(Notifications.self).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        
        notificationCount = allNotifications?.count ?? 0
        let count =  notificationCount
        if count == 0 {
            self.notificationsLabel?.text = "No new notifications".localized
        }
        else {
            self.notificationsLabel?.text = "\(count) " + "new notifications".localized
        }
        
        
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
    }
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
       
       override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
           viewDidAppear?()
       }
    
    @IBAction func markAllAsReadAction(_ sender: Any) {
        markAsReadAllActions?()
        
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        allNotifications = []
        self.allNotifications = realm?.objects(Notifications.self).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        
        notificationCount = allNotifications?.count ?? 0
        let count =  notificationCount
        if count == 0 {
            self.notificationsLabel?.text = "No new notifications".localized
        }
        else {
            self.notificationsLabel?.text = "\(count) " + "new notifications".localized
        }
        
        self.hideLoading()
        self.tableView.reloadData()
    }
}

extension NotificationController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = allNotifications?[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.enquiryId.text = "Enquiry Id: \(notification?.code ?? "")"
        cell.createdOn.text = Date().ttceFormatter(isoDate: "\(notification?.createdOn ?? "")")
        cell.companyName.text = notification?.companyName
        if notification?.type == "Qc Received" {
            cell.type.text = (notification?.type ?? "") + " for " + (notification?.details ?? "")
        }else if notification?.type == "Yarn dye" {
            cell.type.text = (notification?.type ?? "") + " " + (notification?.details ?? "")
        }else{
           cell.type.text = notification?.type
        }
        cell.productDesc.text = notification?.productDesc
        
        let notificationType = notification?.type
        var enquiryImage: UIImage!
        
        switch notificationType {
            case "Enquiry Generated", "Enquiry Closed":
                enquiryImage = UIImage.init(named: "Enquiry")
            case "Moq Received","Moq accepted":
                enquiryImage = UIImage.init(named: "MOQ")
            case "Pi finalized", "Tax Invoice Raised", "Delivery Challan Uploaded", "Order Received":
                enquiryImage = UIImage.init(named: "Pi")
            case "Advance Payment Received", "Advanced Payment Accepted":
                enquiryImage = UIImage.init(named: "AdvancePayment")
            case "Change Requested Initiated","Change Requested Accepted":
                enquiryImage = UIImage.init(named: "ChangeRequest")
            default:
                enquiryImage = UIImage.init(named: "Enquiry")
        }
        cell.enquiryIcon.image = enquiryImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsRead = UIContextualAction(style: .normal, title: "\u{2713}\u{2713}\n Mark as read") { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let notification = self.allNotifications?[indexPath.row]
            let index = indexPath.row
            let id = notification?.entityID ?? 0
            self.markasRead?(id, index)
            success(true)
        }
        markAsRead.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
//        markAsRead.image = UIImage.init(named: "delete")
        
        return UISwipeActionsConfiguration(actions: [markAsRead])
    }
}

extension NotificationController: OfflineRequestManagerDelegate {
    func offlineRequest(withDictionary dictionary: [String : Any]) -> OfflineRequest? {
        return OfflineNotificationRequest(dictionary: dictionary)
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, shouldAttemptRequest request: OfflineRequest) -> Bool {
        return true
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, didUpdateConnectionStatus connected: Bool) {
        
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, didFinishRequest request: OfflineRequest) {
      
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, requestDidFail request: OfflineRequest, withError error: Error) {
        
    }
}




