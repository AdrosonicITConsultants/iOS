//
//  AdminNotificationController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 04/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class AdminNotificationController: UIViewController {
    var allNotifications: [AdminNotifications]?
    var reachabilityManager = try? Reachability()
    var markasRead: ((_ notificationId: Int, _ index: Int) -> ())?
    var markAsReadAllActions: (() -> ())?
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var notificationCount: Int = 0
    let reuseIdentifier = "AdminNotificationView"
    let realm = try? Realm()
    var allNotificationIds: [Int] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        try? reachabilityManager?.startNotifier()
        viewWillAppear?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           viewWillAppear?()
       }
       
       override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
           viewDidAppear?()
       }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        allNotifications = []
        self.allNotifications = realm?.objects(AdminNotifications.self).filter("%K IN %@","notificationId", allNotificationIds).sorted(byKeyPath: "notificationId", ascending: false).compactMap({$0})
        
//        notificationCount = allNotifications?.count ?? 0
//        let count =  notificationCount
//        if count == 0 {
//            self.notificationsLabel?.text = "No new notifications".localized
//        }
//        else {
//            self.notificationsLabel?.text = "\(count) " + "new notifications".localized
//        }
        
        self.hideLoading()
        self.tableView.reloadData()
    }
    
}

extension AdminNotificationController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AdminNotificationView
       if let obj = allNotifications?[indexPath.row] {
        cell.customEnquiry.text = obj.notificationType
        cell.Date.text = (Date().ttceFormatter(isoDate: obj.createdOn ?? ""))
        cell.enquiryCode.text = obj.code
        cell.productDesc.text = obj.productDesc
       }
       return cell
    }
    
    
}
