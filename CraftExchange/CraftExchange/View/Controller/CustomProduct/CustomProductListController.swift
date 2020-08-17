//
//  CustomProductListController.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class CustomProductListController: UITableViewController {
    
    weak var dataSource: TableViewRealmDataSource<Results<CustomProduct>>?
    let reuseIdentifier = "BuyerProductCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var deleteAllCustomProducts: (() -> ())?
    var deleteProduct: ((_ prodId: Int) -> ())?
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        initTable()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(style: .plain)
        initTable()
    }
    
    func initTable() {
//        refreshControl = UIRefreshControl()
//        tableView.refreshControl = refreshControl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        refreshControl?.sendActions(for: .valueChanged)
        try? reachabilityManager?.startNotifier()
        
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
        let rightButtonItem = UIBarButtonItem.init(title: "Delete All".localized, style: .plain, target: self, action: #selector(deleteAllCustomProduct))
        rightButtonItem.tintColor = .red
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      viewDidAppear?()
    }
    
    func endRefresh() {
        if let refreshControl = refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    @objc func deleteAllCustomProduct() {
        deleteAllCustomProducts?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        reachabilityManager?.whenReachable = nil
        reachabilityManager?.whenUnreachable = nil
        reachabilityManager?.stopNotifier()
        viewWillAppear = nil
        applicationEnteredForeground = nil
    }
}

extension CustomProductListController: CustomProductCellProtocol {
    func deleteCustomProduct(withId: Int) {
        deleteProduct?(withId)
    }
}

extension CustomProductListController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}
