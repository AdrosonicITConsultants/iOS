//
//  ChatListController.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class ChatListController: UIViewController {
    
    let reuseIdentifier = "ChatCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allChat: [Chat]?
    var allChatResults: Results<Chat>?
    var markasRead: ((_ notificationId: Int) -> ())?
    var chatList: [Int] = []
    var newChatList: [Int] = []
    let realm = try? Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    @IBOutlet weak var addNewChat: UIButton!
    
    @IBOutlet weak var recentButton: UIButton!
    @IBOutlet weak var pullToRefreshButton: UIButton!
    @IBOutlet weak var escalationsButton: UIButton!
    @IBOutlet weak var chatListSearchBar: UISearchBar!
    var searchText: String = ""
    
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if KeychainManager.standard.userRoleId == 2{
            chatListSearchBar.placeholder = "search by enquiry/ artisan's name"
        }
        
        self.recentButton.isUserInteractionEnabled = false
        self.pullToRefreshButton.isUserInteractionEnabled = false
        self.escalationsButton.isUserInteractionEnabled = false
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        self.allChatResults = realm?.objects(Chat.self).filter("%K == %@","isOld",true ).sorted(byKeyPath: "lastUpdatedOn", ascending: false)
        self.setData()
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
        if self.reachabilityManager?.connection == .unavailable {
            
            self.allChatResults = realm?.objects(Chat.self).filter("%K == %@","isOld",true ).sorted(byKeyPath: "lastUpdatedOn", ascending: false)
            
            
        }else{
            allChatResults = realm?.objects(Chat.self).filter("%K IN %@","entityID",chatList ).sorted(byKeyPath: "lastChatDate", ascending: false)
        }
        
        self.setData()
        self.hideLoading()
        
    }
    
    func setData() {
        allChat = allChatResults?.compactMap({$0})
        
        if searchText != "" {
            let query = NSCompoundPredicate(type: .or, subpredicates:
                [NSPredicate(format: "enquiryNumber contains[c] %@",searchText),
                 NSPredicate(format: "buyerCompanyName contains[c] %@",searchText)])
            
            allChat = allChatResults?.filter(query).sorted(byKeyPath: "lastChatDate", ascending: false).compactMap({$0})
            
        }
        emptyView.isHidden = allChat?.count == 0 ? false : true
        self.tableView.reloadData()
    }
    
    @IBAction func addNewChatSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ChatListService(client: client).createNewScene() as! ChatNewListController
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
}

extension ChatListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChat?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        if let obj = allChat?[indexPath.row] {
            cell.configure(obj)
            cell.lastUpdatedOn.text = Date().ttceFormatter(isoDate: obj.lastChatDate ?? "" )
            cell.lastUpdatedTime.text = Date().ttceFormatterTime(isoDate: obj.lastChatDate ?? "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            if let obj = allChat?[indexPath.row] {
                let vc = ChatDetailsService(client: client).createScene(forChat: obj, enquiryId: obj.enquiryId) as! ChatDetailsController
                vc.modalPresentationStyle = .fullScreen
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsRead = UIContextualAction(style: .normal, title: "\u{2713}\u{2713}\n Mark as read") { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let chat = self.allChat?[indexPath.row]
            // let index = indexPath.row
            let id = chat?.enquiryId
            self.markasRead?(id!)
            success(true)
        }
        markAsRead.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        //        markAsRead.image = UIImage.init(named: "delete")
        
        return UISwipeActionsConfiguration(actions: [markAsRead])
    }
    
    
}

extension ChatListController: UISearchBarDelegate {
    
    
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

