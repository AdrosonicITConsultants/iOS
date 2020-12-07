//
//  ArtisanProdCatalogueController.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class ArtisanProdCatalogueController: UITableViewController {
    
    weak var dataSource: TableViewRealmDataSource<Results<Product>>?
    let reuseIdentifier = "ArtisanProductCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var refreshCategory: ((_ catId: Int) -> ())?
    var refreshData: (() -> ())?
    var fromFilter: Bool = false
    var loadPage = 1
    var searchLimitReached = false
    var refreshSearchResult: ((_ loadPage: Int) -> ())?
    var currentCat: ProductCategory?
    
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
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? reachabilityManager?.startNotifier()
        self.setupSideMenu(true)
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        if fromFilter {
            let rightButtonItem = UIBarButtonItem.init(title: "Filter by Collection".localized, style: .plain, target: self, action: #selector(showCreatorOptions))
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }else {
            let rightButtonItem = UIBarButtonItem.init(title: "Change Category".localized, style: .plain, target: self, action: #selector(showCategory))
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
    }
    
    @objc func pullToRefresh() {
        refreshData?()
    }
    
    func endRefresh() {
        if let refreshControl = refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        self.refreshCategory?(currentCat?.entityID ?? 0)
    }
    
    @objc func showCategory() {
        let alert = UIAlertController.init(title: "Select Category".localized, message: "", preferredStyle: .actionSheet)
        let catgories = Product().getAllProductCatForUser()
        for option in catgories {
            let action = UIAlertAction.init(title: option.prodCatDescription?.localized ?? "", style: .default) { (action) in
                self.title = option.prodCatDescription?.localized
                self.refreshCategory?(option.entityID)
                self.currentCat = option
            }
            alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showCreatorOptions() {
        let textArray = ["Show Both".localized, "Artisan Self Design Collection".localized,"Antaran Co-Design Collection".localized]
        let alert = UIAlertController.init(title: "Please select".localized, message: "", preferredStyle: .actionSheet)
        for option in textArray {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                if let index = textArray.firstIndex(of: option) {
                    if index == 2 {
                        self.refreshCategory?(1)
                    }else {
                        self.refreshCategory?(0)
                    }
                }else {
                    self.refreshCategory?(0)
                }
            }
            alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        reachabilityManager?.whenReachable = nil
        reachabilityManager?.whenUnreachable = nil
        reachabilityManager?.stopNotifier()
        applicationEnteredForeground = nil
    }
}

extension ArtisanProdCatalogueController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Write action code for the trash
        let viewEditAction = UIContextualAction(style: .normal, title:  "View & \n Edit".localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Update action ...")
            success(true)
        })
        viewEditAction.image = UIImage.init(named: "iOS-edit")
        viewEditAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [viewEditAction])
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        if dataSource?.changeset?.count == 1 {
            header.text = " Found \(dataSource?.changeset?.count ?? 0) item"
        }else if dataSource?.changeset?.count ?? 0 > 0 {
            header.text = " Found \(dataSource?.changeset?.count ?? 0) items"
        }else {
            header.text = " No Results Found!".localized
        }
        header.font = .systemFont(ofSize: 15)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if fromFilter || dataSource?.changeset?.count == 0 || dataSource == nil {
            return 40
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if fromFilter && searchLimitReached == false {
            let lastElement = (dataSource?.changeset?.count ?? 0) - 1
            if indexPath.row == lastElement {
                loadPage += 1
                self.refreshSearchResult?(loadPage)
            }
        }
    }
}
