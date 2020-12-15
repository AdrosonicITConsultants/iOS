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
    var viewTransactionReceipt: ((_ transactionObj: TransactionObject, _ isOld: Int, _ isPI: Bool) -> ())?
    var downloadPI: ((_ enquiryId: Int, _ isPI: Bool) -> ())?
    var goToEnquiry: ((_ enquiryId: Int) -> ())?
    var downloadEnquiry: ((_ enquiryId: Int) -> ())?
    var downloadAdvReceipt: ((_ enquiryId: Int) -> ())?
    var downloadRevisedAdvReceipt: ((_ enquiryId: Int) -> ())?
    var downloadFinalReceipt: ((_ enquiryId: Int) -> ())?
}

class TransactionListController: UIViewController {
    
    let reuseIdentifier = "TransactionTitleRow"
    let detailRowIdentifier = "TransactionDetailRow"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allTransactions: Results<TransactionObject>?
    let realm = try! Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var transactionSearchBar: UISearchBar!
    //    @IBOutlet weak var emptyView: UIView!
    lazy var viewModel = TransactionListViewModel()
    var mySection: Int = -1
    var selectedFilter: Int = 0
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.register(UINib(nibName: detailRowIdentifier, bundle: nil), forCellReuseIdentifier: detailRowIdentifier)
        try? reachabilityManager?.startNotifier()
        self.setupSideMenu(true)
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
        let rightBarButtomItem1 = UIBarButtonItem(customView: self.notificationBarButton())
        let rightBarButtomItem2 = self.searchBarButton()
        navigationItem.rightBarButtonItems = [rightBarButtomItem1, rightBarButtomItem2]
        setData()
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear?()
    }
    
    @objc func pullToRefresh() {
        viewModel.viewWillAppear?()
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        self.setData()
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    func setData() {
        allTransactions = TransactionObject.getAllTransactionObjects().filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).sorted(byKeyPath: "modifiedOn", ascending: false)
        if selectedFilter != 0{
            if selectedFilter == 1 {
                //P ID
                allTransactions = allTransactions?.filter("%K != 0 OR %K != 0", "piId","piHistoryId").sorted(byKeyPath: "modifiedOn", ascending: false)
            }else if selectedFilter == 2 {
                //Payment ID
                allTransactions = allTransactions?.filter("%K != 0", "paymentId").sorted(byKeyPath: "modifiedOn", ascending: false)
            }else if selectedFilter == 3 {
                //Tax Invoice ID
                allTransactions = allTransactions?.filter("%K != 0", "taxInvoiceId").sorted(byKeyPath: "modifiedOn", ascending: false)
            }else if selectedFilter == 4 {
                //Challan ID
                allTransactions = allTransactions?.filter("%K != 0", "challanId").sorted(byKeyPath: "modifiedOn", ascending: false)
            }
        }
        if searchText != "" {
            allTransactions = allTransactions?.filter("%K contains[c] %@", "enquiryCode",searchText).sorted(byKeyPath: "modifiedOn", ascending: false)
        }
    }
    
    @IBAction func filterSelected(_ sender: Any) {
        let alert = UIAlertController.init(title: "Select".localized, message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.filterButton.setTitle("  Filter".localized, for: .normal)
            self.selectedFilter = 0
            self.setData()
            self.tableView.reloadData()
        }
        alert.addAction(all)
        let textArray = ["P ID".localized, "Payment ID".localized,"Tax Invoice ID".localized, "Challan ID".localized]
        alert.title = "Please Select".localized
        for option in textArray {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                if let index = textArray.firstIndex(of: option) {
                    self.filterButton.setTitle("  \(option)", for: .normal)
                    self.selectedFilter = index + 1
                    self.setData()
                    self.tableView.reloadData()
                }else {
                    self.setData()
                }
            }
            alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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

extension TransactionListController: TransactionListProtocol, AcceptedPIViewProtocol, TransactionReceiptViewProtocol {
    func viewTransactionReceipt(tag: Int) {
        if let transaction = allTransactions?[tag] {
            let invoiceStateArray = [1,2,3,4,5]
            let advancePaymentArray = [6,8,10]
            let revisedAdvancePaymentArray = [24,25,26,27,28,29]
            let taxInvoiceArray = [12,13]
            let finalPaymentarray = [14,16,18]
            if invoiceStateArray.contains(transaction.accomplishedStatus) {
                self.viewModel.viewTransactionReceipt?(transaction, 0, true)
            }else if advancePaymentArray.contains(transaction.accomplishedStatus){
                self.viewModel.downloadAdvReceipt?(transaction.enquiryId)
            }else if revisedAdvancePaymentArray.contains(transaction.accomplishedStatus){
                self.viewModel.downloadRevisedAdvReceipt?(transaction.enquiryId)
            }else if finalPaymentarray.contains(transaction.accomplishedStatus){
                self.viewModel.downloadFinalReceipt?(transaction.enquiryId)
            }else if taxInvoiceArray.contains(transaction.accomplishedStatus) {
                self.viewModel.viewTransactionReceipt?(transaction, 0, false)
            }
        }
    }
    
    func backButtonSelected() {
        self.view.hideAcceptedPIView()
    }
    
    func downloadButtonSelected(isOld: Bool) {
        let view = self.view.viewWithTag(129) as! AcceptedPIView
        let entityId = view.entityIdLabel.text?.components(separatedBy: "-").last ?? "0"
        self.viewModel.downloadPI?(Int(entityId) ?? 0, isOld)
    }
    
    func TIdownloadButtonSelected() {
        let view = self.view.viewWithTag(129) as! AcceptedPIView
        let entityId = view.entityIdLabel.text?.components(separatedBy: "-").last ?? "0"
        self.viewModel.downloadPI?(Int(entityId) ?? 0, false)
    }
    
    func cancelBtnSelected() {
        self.view.hideTransactionReceiptView()
    }
}

extension TransactionListController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allTransactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mySection == section) {
            //transaction title + details
            return 2
        } else {
            //transaction title
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TransactionTitleRow
            if let transaction = allTransactions?[indexPath.section] {
                cell.configure(transaction)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: detailRowIdentifier, for: indexPath) as! TransactionDetailRow
            if let transaction = allTransactions?[indexPath.section] {
                cell.configure(transaction)
                cell.invoiceButton.tag = indexPath.section
                cell.delegate = self
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
        }else {
            let transaction = allTransactions?[indexPath.section]
            if let obj = Enquiry().searchEnquiry(searchId: transaction?.enquiryId ?? 0) {
                self.viewModel.goToEnquiry?(obj.enquiryId)
            }else {
                self.viewModel.downloadEnquiry?(transaction?.enquiryId ?? 0)
            }
        }
    }
}

extension TransactionListController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchBar.text ?? ""
        setData()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.text = ""
        searchText = ""
        setData()
        self.tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
