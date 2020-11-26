//
//  AdminChatEscalationController.swift
//  CraftExchange
//
//  Created by Kalyan on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class AdminChatEscalationController: UIViewController {
    var applicationEnteredForeground: (() -> ())?
    var allEscalations: [AdminChatEscalationObject]?
    var reachabilityManager = try? Reachability()
    var viewWillAppear: (() -> ())?
    let reuseIdentifier = "AdminChatEscalationCell"
    let realm = try? Realm()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var itemsFoundText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allEscalations = []
        self.view.backgroundColor = #colorLiteral(red: 0.3019607843, green: 0.1254901961, blue: 0.3490196078, alpha: 1)
        self.tableView.backgroundColor  = #colorLiteral(red: 0.3019607843, green: 0.1254901961, blue: 0.3490196078, alpha: 1)
        definesPresentationContext = false
        //  self.setupSideMenu(false)
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
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
        super.viewWillAppear(true)
            viewWillAppear?()
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        if allEscalations?.count == 0 {
            itemsFoundText.text = "No Escalations Found!"
        }else if allEscalations?.count == 1{
            itemsFoundText.text = "1 Escalation Found"
        }else {
            itemsFoundText.text = "\(allEscalations?.count ?? 0) Escalations Found"
        }
        self.hideLoading()
        self.tableView.reloadData()
    }
    
}

extension AdminChatEscalationController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEscalations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AdminChatEscalationCell
        if let obj = allEscalations?[indexPath.row] {
            cell.configure(obj)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

