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
    var allNotifications: [Notifications]?
    var reachabilityManager = try? Reachability()
    var markasRead: ((_ notificationId: Int, _ index: Int) -> ())?
    var markAsReadAllActions: (() -> ())?
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var notificationCount: Int = 0
    let reuseIdentifier = "AdminNotificationView"
   
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
    
    @IBAction func markAllAsReadAction(_ sender: Any) {
        markAsReadAllActions?()
        
    }
}

extension AdminNotificationController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 100
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       var cell:AdminNotificationView? = tableView.dequeueReusableCell(withIdentifier:"AdminNotificationView") as? AdminNotificationView
       if cell == nil{
           tableView.register(UINib.init(nibName: "AdminNotificationView", bundle: nil), forCellReuseIdentifier: "AdminNotificationView")

       }
        cell?.EnquiryId.text = "AN-FR-YU-TU"
        cell?.customEnquiry.text = "Custom Enquiry"
        cell?.Date.text = "21-06-2020"
        cell?.TImeLabel.text = "21:12"
        cell?.RedirectRequired.text = "Redirect Required"

       return cell!
    }
    
    
}
