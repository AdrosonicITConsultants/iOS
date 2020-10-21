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
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chatNewListSearchBar: UISearchBar!
    var searchText: String = ""
    
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pullToRefreshButton.isUserInteractionEnabled = false
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allChat = []
        definesPresentationContext = false
        self.setupSideMenu(false)
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
        viewWillAppear?()
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        allChatResults = realm?.objects(Chat.self).filter("%K IN %@","entityID",newChatList ).sorted(byKeyPath: "lastUpdatedOn", ascending: false)

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
    @IBAction func backButtonSelected(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)

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

                cell.lastMessage.text = ""
                cell.lastUpdatedOn.text = Date().ttceFormatter(isoDate: obj.lastUpdatedOn!)
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
