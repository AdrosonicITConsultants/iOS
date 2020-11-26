//
//  SearchTeammateController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 13/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class SearchTeammateController: UIViewController {
    var reachedSearchLimit = false
    var viewWillAppear: (() -> ())?
    var getAdminRoles: (() -> ())?
    var refreshSearchResult: ((_ loadPage: Int) -> ())?
    var loadPage = 1
    @IBOutlet weak var btnSearch: RoundedButton!
    @IBOutlet weak var backArrowBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var selectRoleLabel: UILabel!
    @IBOutlet weak var SearchTeammateLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roleFilterButton: UIButton!
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    let reuseIdentifier = "TeammateListCell"
    var allUsers: [AdminTeammate]?
    var allUserResults: Results<AdminTeammate>?
    var allRolesResults: Results<AdminRoles>?
    var allRoles: [AdminRoles]?
    var idList: [Int] = []
    var searchText: String = ""
    var adminRoleId: [Int] = []
    
    
    @IBAction func roleFilterButtonSelected(_sender: Any){
        allRolesResults = realm?.objects(AdminRoles.self).filter("%K IN %@","id", adminRoleId)
        
        let alert = UIAlertController.init(title: "", message: "Select role", preferredStyle: .actionSheet)
        
        let any = UIAlertAction.init(title: "Any", style: .default) { (action) in
            self.endRefresh()
        }
        alert.addAction(any)
        
        for role in allRolesResults! {
            let change = UIAlertAction.init(title: role.desc, style: .default) { (action) in
                self.roleFilterButton.titleLabel?.text = role.desc
                self.filterByRole(roleName: role.desc, roleId: role.id)
            }
            alert.addAction(change)
        }

        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    func filterByRole(roleName: String?, roleId: Int){
        allUserResults = realm?.objects(AdminTeammate.self).filter("%K in %@","id", idList)
        allUsers = allUserResults?.compactMap({$0})

        let query = NSCompoundPredicate(type: .or, subpredicates:
            [NSPredicate(format: "role LIKE %@", roleName!)])

        allUsers = allUserResults?.filter(query).sorted(byKeyPath: "id", ascending: false).compactMap({$0})
        
        self.totalLabel.text = "Total: \(allUsers!.count)"
        self.hideLoading()
        self.tableView.reloadData()
        if allUsers?.count != 0 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    
    @IBAction func showAction(_ sender: Any) {
        self.searchText = searchBar.text ?? ""
        endRefresh()
        searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.placeholder = "search by name, email"
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        allUsers = []
        allUserResults = realm?.objects(AdminTeammate.self).filter("%K IN %@","id", idList)
        allUsers = allUserResults?.compactMap({$0})
        
        let rightBarButtomItem = UIBarButtonItem(customView: self.notificationBarButton())
        navigationItem.rightBarButtonItem = rightBarButtomItem
    }
    
    func endRefresh() {
        allUserResults = realm?.objects(AdminTeammate.self).filter("%K IN %@","id", idList)
        allUsers = allUserResults?.sorted(byKeyPath: "id", ascending: false).compactMap({$0})

        self.searchText = searchBar.text ?? ""
        if searchText != "" {
            let query = NSCompoundPredicate(type: .or, subpredicates:
            [NSPredicate(format: "username contains[c] %@", searchText), NSPredicate(format: "email contains[c] %@", searchText)])
            
            allUsers = allUserResults?.filter(query).sorted(byKeyPath: "id", ascending: false).compactMap({$0})
        }
        
        self.totalLabel.text = "Total: \(allUsers!.count)"
        self.hideLoading()
        self.tableView.reloadData()
        if allUsers?.count != 0 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
}
    
    extension SearchTeammateController: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return allUsers?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TeammateListCell
            if let obj = allUsers?[indexPath.row] {
                cell.name.text = obj.username
                cell.role.text = obj.role
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if self.allUsers?.count ?? 0 > 0 && self.reachedSearchLimit == false {
                let lastElement = (allUsers?.count ?? 0) - 1
                if indexPath.row == lastElement {
                    loadPage += 1
                    print(loadPage)
                    self.refreshSearchResult?(loadPage)
                }
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                if let obj = allUsers?[indexPath.row] {
                    let vc = MarketingTeammateService(client: client).createSceneTeammateDetail(forTeammate: obj, id: obj.id) as! SearchedTeammateInfoController
                    vc.modalPresentationStyle = .fullScreen
                    navigationController?.pushViewController(vc, animated: true)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }

extension SearchTeammateController: UISearchBarDelegate {
  
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
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


