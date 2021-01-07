//
//  ChatNewListController.swift
//  CraftExchange
//
//  Created by Kalyan on 14/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class ChatNewListController: UIViewController {
    
    let reuseIdentifier = "ChatCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allChat: [Chat]?
    var allChatResults: Results<Chat>?
    
    var newChatList: [Int] = []
    let realm = try? Realm()
    var initiateChat: ((_ enquiryId: Int) -> ())?
    
    @IBOutlet weak var pullToRefreshButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    @IBOutlet weak var chatNewListSearchBar: UISearchBar!
    var searchText: String = ""
    
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if KeychainManager.standard.userRoleId == 2{
            chatNewListSearchBar.placeholder = "search by enquiry/ artisan's name"
        }
        
        self.pullToRefreshButton.isUserInteractionEnabled = false
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        self.allChatResults = realm?.objects(Chat.self).filter("%K == %@","userId",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","isOld",false ).sorted(byKeyPath: "lastUpdatedOn", ascending: false)
        self.setData()
        definesPresentationContext = false
        self.setupSideMenu(true)
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        if KeychainManager.standard.userID != nil && KeychainManager.standard.userID != 0 {
            tableView.refreshControl?.beginRefreshing()
        }
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            
            self.allChatResults = realm?.objects(Chat.self).filter("%K == %@","userId",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","isOld",false ).sorted(byKeyPath: "lastUpdatedOn", ascending: false)
            
            
        }else{
            allChatResults = realm?.objects(Chat.self).filter("%K IN %@","entityID",newChatList ).sorted(byKeyPath: "lastUpdatedOn", ascending: false)
        }
        
        self.setData()
        self.hideLoading()
        
    }
    
    func setData(){
        allChat = allChatResults?.compactMap({$0})
        
        if searchText != "" {
            let query = NSCompoundPredicate(type: .or, subpredicates:
                [NSPredicate(format: "enquiryNumber contains[c] %@",searchText),
                 NSPredicate(format: "buyerCompanyName contains[c] %@",searchText)])
            
            allChat = allChatResults?.filter(query).sorted(byKeyPath: "lastUpdatedOn", ascending: false).compactMap({$0})
            
        }
        
        emptyView.isHidden = allChat?.count == 0 ? false : true
        self.tableView.reloadData()
    }
    
}

extension ChatNewListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChat?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        if let obj = allChat?[indexPath.row] {
            cell.configure(obj)
            //            cell.lastMessage.text = ""
            //            if let date = obj.lastUpdatedOn ?? obj.lastChatDate {
            //                cell.lastUpdatedOn.text = Date().ttceFormatter(isoDate: date)
            //            }
            //            cell.lastUpdatedTime.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let id = allChat?[indexPath.row].enquiryId
        
        self.initiateChat?(id!)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        let header = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: tableView.frame.size.width-40, height: 60))
        header.textAlignment = .left
        header.textColor = .lightGray
        header.font = .systemFont(ofSize: 16)
        header.numberOfLines = 2
        if KeychainManager.standard.userID == nil || KeychainManager.standard.userID == 0 {
            header.text = "Please login to continue"
        }else {
            header.text = "No new records available to be added"
        }
        labelView.addSubview(header)
        return labelView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if allChat?.count == 0 {
            return 60
        }
        return 0
    }
    
}

extension ChatNewListController: UISearchBarDelegate {
    
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
