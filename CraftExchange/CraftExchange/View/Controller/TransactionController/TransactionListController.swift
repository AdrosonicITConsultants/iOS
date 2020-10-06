//
//  TransactionListController.swift
//  CraftExchange
//
//  Created by Preety Singh on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class TransactionListViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var filterTransactionList: ((_ index: Int) -> ())?
    var searchTransactionList: ((_ searchText: String) -> ())?
}

class TransactionListController: UIViewController {
    
    let reuseIdentifier = "TransactionTitleRow"
    let detailRowIdentifier = "TransactionDetailRow"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allTransactions: Results<TransactionObject>?
    var selectedTransactions: Results<TransactionObject>?
    var uniqueEnquiryIds: [Int]?
    let realm = try! Realm()
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var emptyView: UIView!
    lazy var viewModel = TransactionListViewModel()
    var mySection: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.register(UINib(nibName: detailRowIdentifier, bundle: nil), forCellReuseIdentifier: detailRowIdentifier)
        try? reachabilityManager?.startNotifier()
        self.setupSideMenu(false)
        uniqueEnquiryIds = []
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
        let rightBarButtomItem1 = UIBarButtonItem(customView: self.notificationBarButton())
        let rightBarButtomItem2 = self.searchBarButton()
        navigationItem.rightBarButtonItems = [rightBarButtomItem1, rightBarButtomItem2]
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear?()
    }
    
    func endRefresh() {
        self.setData()
        self.tableView.reloadData()
    }
    
    func setData() {
        if mySection == -1 {
            allTransactions = TransactionObject.getAllTransactionObjects()
        }else {
            selectedTransactions = TransactionObject.getTransactionObjects(searchId: uniqueEnquiryIds?[mySection] ?? 0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        reachabilityManager?.whenReachable = nil
        reachabilityManager?.whenUnreachable = nil
        reachabilityManager?.stopNotifier()
        viewModel.viewWillAppear = nil
        applicationEnteredForeground = nil
    }
}

extension TransactionListController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return uniqueEnquiryIds?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mySection == section) {
            ///we want the number of people plus the header cell
            return TransactionObject.getTransactionObjects(searchId: uniqueEnquiryIds?[section] ?? 0).count+1
        } else {
            ///we just want the header cell
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TransactionTitleRow
            if let transaction = TransactionObject.getTransactionObjects(searchId: uniqueEnquiryIds?[indexPath.section] ?? 0).first {
                cell.configure(transaction)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: detailRowIdentifier, for: indexPath) as! TransactionDetailRow
            if let transaction = selectedTransactions?[indexPath.row-1] {
                cell.configure(transaction)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            if mySection == indexPath.section {
                mySection = -1
                setData()
                self.tableView.reloadSections(NSIndexSet.init(index: indexPath.section) as IndexSet, with: .none)
            }else {
                let oldSection = mySection
                if oldSection != -1 {
                    mySection = -1
                    self.tableView.reloadSections(NSIndexSet.init(index: oldSection) as IndexSet, with: .none)
                }
                mySection = indexPath.section
                setData()
                self.tableView.reloadSections(NSIndexSet.init(index: indexPath.section) as IndexSet, with: .none)
            }
        }
    }
}
