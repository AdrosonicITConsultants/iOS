//
//  SelectArtisanController.swift
//  CraftExchange
//
//  Created by Kalyan on 23/11/20.
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
import Reachability
import ReactiveKit
import MessageUI
import MobileCoreServices


class SelectArtisanController: UIViewController {
    //  @IBOutlet weak var scrollView: UIScrollView!
    let reuseIdentifier = "SelectArtisanBrandCell"
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var artisanSearchBar: UISearchBar!
    @IBOutlet weak var clusterFilterButton: RoundedButton!
    @IBOutlet weak var applyFilterButton: UIButton!
    @IBOutlet weak var artisanCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var allArtisans: [SelectArtisanBrand]?
    var allArtisansResults: Results<SelectArtisanBrand>?
    var viewWillAppear: (() -> ())?
    var clusterFilterValue = "All"
    var artisanID = 0
    var indexRow = -1
    var searchText: String = ""
    var saveProductSelected: ((_ artisanID: Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clusterFilterButton.borderColour = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        
        artisanSearchBar.placeholder = "search by weaverID, brand, cluster"
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allArtisans = []
        
        definesPresentationContext = false
        //  self.setupSideMenu(false)
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        // self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let back = UIBarButtonItem(image: UIImage.init(systemName: "arrow.left"), style: .done, target: self, action: #selector(backSelected(_:)))
        back.tintColor = .darkGray
        self.navigationItem.leftBarButtonItem =  back
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
    
    @objc func backSelected(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        if self.reachabilityManager?.connection == .unavailable {
            
            
            self.allArtisansResults = realm?.objects(SelectArtisanBrand.self)
            self.allArtisans = allArtisansResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            
        }else{
            
            self.allArtisansResults = realm?.objects(SelectArtisanBrand.self)
            self.allArtisans = allArtisansResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            
        }
        checkFilter()
        if searchText != "" {
            let query = NSCompoundPredicate(type: .or, subpredicates:
                [NSPredicate(format: "weaverId contains[c] %@",searchText),
                 NSPredicate(format: "cluster contains[c] %@",searchText), NSPredicate(format: "brand contains[c] %@",searchText)])
            
            allArtisans = allArtisansResults?.filter(query).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            
        }
        
        let count = allArtisans?.count ?? 0
        self.artisanCountLabel.text = "Found \(count) Artisan Brands"
        
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    @IBAction func saveBtnSelected(_ sender: Any) {
        if self.artisanID == 0 {
            self.alert("Error".localized, "Please select artisan".localized) { (alert) in
                
            }
        }else{
            saveProductSelected?(self.artisanID)
            // print(self.artisanID)
        }
        
    }
    
    @IBAction func clusterFilterBtnSelected(_ sender: Any) {
        self.presentClusterInputActionsheet()
    }
    
    func presentClusterInputActionsheet(){
        let alert = UIAlertController.init(title: "", message: "Choose", preferredStyle: .actionSheet)
        
        let all = UIAlertAction.init(title: "All", style: .default) { (action) in
            self.clusterFilterValue = "All"
            self.clusterFilterButton.setTitle("All", for: .normal)
        }
        alert.addAction(all)
        
        if let allClusters = realm?.objects(ClusterDetails.self).sorted(byKeyPath: "entityID") {
            
            for cluster in allClusters {
                let change = UIAlertAction.init(title: cluster.clusterDescription, style: .default) { (action) in
                    self.clusterFilterButton.setTitle(cluster.clusterDescription, for: .normal)
                    self.clusterFilterValue = cluster.clusterDescription ?? ""
                }
                alert.addAction(change)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func applyFilterBtnSelected(_ sender: Any) {
        checkFilter()
        let count = allArtisans?.count ?? 0
        self.artisanCountLabel.text = "Found \(count) Artisan Brands"
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    func checkFilter() {
        
        if self.clusterFilterValue != "All" {
            self.allArtisansResults = realm?.objects(SelectArtisanBrand.self)
            self.allArtisans = allArtisansResults?.filter("%K == %@","cluster",clusterFilterValue ).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }else{
            self.allArtisansResults = realm?.objects(SelectArtisanBrand.self)
            self.allArtisans = allArtisansResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }
        
        
    }
    
}

extension SelectArtisanController: UITableViewDataSource, UITableViewDelegate, ProductCatalogueProtocol{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allArtisans?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SelectArtisanBrandCell
        if let obj = allArtisans?[indexPath.row] {
            cell.configure(obj)
            if self.artisanID == obj.entityID {
                cell.selectToggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
            }else{
                cell.selectToggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        print(indexPath.row)
        //   guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedFilterRow = self.indexRow
        if selectedFilterRow == indexPath.row {
            return
        }
        
        // Remove the checkmark from the previously selected filter item.
        if let cell3 = tableView.cellForRow(at: IndexPath(row: selectedFilterRow, section: indexPath.section)) as? SelectArtisanBrandCell {
            cell3.selectToggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        }
        
        // Remember this selected filter item.
        if let obj = allArtisans?[indexPath.row] {
            let cell2 = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! SelectArtisanBrandCell
            cell2.selectToggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
            
            self.indexRow = indexPath.row
            self.artisanID = obj.entityID
        }
        
    }
    
}

extension SelectArtisanController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchBar.text ?? ""
        endRefresh()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.text = ""
        searchText = ""
        endRefresh()
        searchBar.resignFirstResponder()
    }
}

extension SelectArtisanController: OfflineRequestManagerDelegate {
    func offlineRequest(withDictionary dictionary: [String : Any]) -> OfflineRequest? {
        return OfflineProductRequest(dictionary: dictionary)
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
