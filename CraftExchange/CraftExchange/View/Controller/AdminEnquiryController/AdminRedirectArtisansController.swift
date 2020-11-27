//
//  AdminRedirectArtisansController.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
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


class AdminRedirectArtisansController: UIViewController {
    
    let reuseIdentifier = "AdminRedirectArtisansCell"
    @IBOutlet weak var redirectButton: UIButton!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var enquiryDate: UILabel!
    @IBOutlet weak var artisansSearchBar: UISearchBar!
    @IBOutlet weak var clusterFilterButton: RoundedButton!
    @IBOutlet weak var applyFilterButton: UIButton!
    @IBOutlet weak var artisansHeaderView: UIView!
    @IBOutlet weak var foundItemsView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkAllbutton: UIButton!
    
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var allArtisans: [AdminRedirectArtisan]?
    var viewWillAppear: (() -> ())?
    var clusterFilterValue = 0
    var artisanIDs:[Int] = []
    var indexRow = -1
    var searchText: String = ""
    var redirectEnquiry: ((_ artisanIDs: String) -> Void)?
    var checkedAll = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clusterFilterButton.borderColour = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allArtisans = []
        foundItemsView.text = " No Results Found!"
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
        //        let clickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAllEnquiriesCliked))
        //        self.artisansHeaderView.addGestureRecognizer(clickGesture)
        
        
    }
    @IBAction func checkAllButtonSelected(_ sender: Any) {
        var validIds: [Int] = []
        
        if allArtisans != nil  && allArtisans != []{
            for obj in allArtisans! {
                if obj.artisan?.status == 1 && obj.isMailSent != 1{
                    validIds.append(obj.artisan?.entityID ?? 0)
                }
            }
        }
        if self.artisanIDs.count == validIds.count {
            self.artisanIDs.removeAll()
            self.checkAllbutton.setImage(UIImage.init(systemName: "circle"), for: .normal)
            self.checkedAll = 2
        }else{
            self.artisanIDs = validIds
            self.checkAllbutton.setImage(UIImage.init(named: "blue tick"), for: .normal)
            self.checkedAll = 1
        }
        self.tableView.reloadData()
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
        
        if allArtisans?.count == 1 {
            foundItemsView.text = " Found \(allArtisans?.count ?? 0) item"
        }else if allArtisans?.count ?? 0 > 0 {
            foundItemsView.text = " Found \(allArtisans?.count ?? 0) items"
        }else {
            foundItemsView.text = " No Results Found!"
        }
        
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    @IBAction func redirectButtonSelected(_ sender: Any) {
        
        print(artisanIDs)
        if artisanIDs.count == 0 {
            self.alert("Please select at least one artisan")
        }else{
            var str = ""
            for id in artisanIDs
            {
                let firstIndex = artisanIDs.firstIndex(of: id)
                if firstIndex == 0{
                    str += "\(id)"
                }else{
                    str += ",\(id)"
                }
                
            }
            print(str)
            self.redirectEnquiry?(str)
        }
        
    }
    @IBAction func clusterFilterButton(_ sender: Any) {
        self.presentClusterInputActionsheet()
    }
    
    func presentClusterInputActionsheet(){
        let alert = UIAlertController.init(title: "", message: "Choose", preferredStyle: .actionSheet)
        
        let all = UIAlertAction.init(title: "All", style: .default) { (action) in
            self.clusterFilterValue = 0
            self.clusterFilterButton.setTitle("All", for: .normal)
        }
        alert.addAction(all)
        
        if let allClusters = realm?.objects(ClusterDetails.self).sorted(byKeyPath: "entityID") {
            
            for cluster in allClusters {
                let change = UIAlertAction.init(title: cluster.clusterDescription, style: .default) { (action) in
                    self.clusterFilterButton.setTitle(cluster.clusterDescription, for: .normal)
                    self.clusterFilterValue = cluster.entityID
                }
                alert.addAction(change)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func applyFilterButtonSelected(_ sender: Any) {
        allArtisans?.removeAll()
        artisansSearchBar.resignFirstResponder()
        viewWillAppear?()
    }
    
}

extension AdminRedirectArtisansController: UITableViewDataSource, UITableViewDelegate, ProductCatalogueProtocol{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allArtisans?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AdminRedirectArtisansCell
        if let obj = allArtisans?[indexPath.row] {
            cell.configure(obj)
            cell.delegate = self
            cell.indexpath = indexPath
            if let status = obj.artisan?.status{
                if status == 1 && obj.isMailSent == 0 {
                    if checkedAll == 0{
                        var i = 0
                        for name in artisanIDs {
                            if name == obj.artisan?.entityID {
                                i = 1
                            }
                        }
                        if i == 1{
                            cell.checkButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                        }else if i == 0 {
                            cell.checkButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                        }
                        
                    }else if checkedAll == 1 {
                        cell.checkButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                        var i = 0
                        for name in artisanIDs {
                            if name == obj.artisan?.entityID {
                                i = 1
                            }
                        }
                        if i == 1{
                            cell.checkButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                        }else if i == 0 {
                            cell.checkButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                        }
                    }else if checkedAll == 2{
                        cell.checkButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                        var i = 0
                        for name in artisanIDs {
                            if name == obj.artisan?.entityID {
                                i = 1
                            }
                        }
                        if i == 1{
                            cell.checkButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                        }else if i == 0 {
                            cell.checkButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                        }
                    }
                }
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
          tableView.deselectRow(at: indexPath, animated: false)
           
           
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}

extension AdminRedirectArtisansController: UISearchBarDelegate, AdminRedirectArtisansProtocol{
    
    ///check button methods
    func checkButtonSelected(tag: IndexPath) {
        guard let cell = tableView.cellForRow(at: tag) as? AdminRedirectArtisansCell else { return }
        
        if let obj = allArtisans?[tag.row] {
            if cell.ischecked {
                if let status = obj.artisan?.status {
                    if status == 1 && obj.isMailSent == 0{
                        if artisanIDs != [] {
                            var i = 0
                            for name in artisanIDs {
                                if name == obj.artisan?.entityID {
                                    i = 1
                                }
                            }
                            if i == 0 {
                                self.artisanIDs.append(obj.artisan?.entityID ?? 0)
                            }
                        }else{
                            self.artisanIDs.append(obj.artisan?.entityID ?? 0)
                            
                        }
                    }
                    
                }
            }else{
                if let firstIndex = artisanIDs.firstIndex(of: obj.artisan!.entityID) {
                    artisanIDs.remove(at: firstIndex)
                }
            }
            
        }
        
    }
    
    /// search methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applyFilterButton.sendActions(for: .touchUpInside)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        applyFilterButton.sendActions(for: .touchUpInside)
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
}
