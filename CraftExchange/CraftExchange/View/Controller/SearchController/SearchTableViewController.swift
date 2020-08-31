//
//  SearchTableViewController.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit
import SideMenu
import Reachability
import RealmSwift
import JGProgressHUD

class SearchTableViewController: UITableViewController, Searchable {
    var searchController: UISearchController?
    var searchWithSearchString: ((String) -> ())?
    var cancelSearchAction: (() -> ())?
    var suggestionArray: [[String: Any]]?
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        suggestionArray = []
        dataArray = []
        tableView.register(UINib.init(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        searchController = UISearchController(searchResultsController: nil)
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search products, codes, product type, weaves"
        searchController?.searchBar.delegate = self
        searchController?.searchBar.sizeToFit()
        definesPresentationContext = true
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        setup(with: searchController, and: tableView)
    }
    
}

extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
        cell.titleLbl.text = dataArray[indexPath.row]
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController?.resignFirstResponder()
        let selectedSuggestion = suggestionArray?[indexPath.row]
//        if selectedSuggestion?["suggestionType"] as? String == "Global" {
            if let selectedString = searchController?.searchBar.text {
                listSearchProduct(searchString: selectedString, type: selectedSuggestion?["suggestionTypeId"] as? Int ?? 5)
            }
//        }else {
//
//            if let selectedString = selectedSuggestion?["suggestion"] as? String {
//                listSearchProduct(searchString: selectedString, type: selectedSuggestion?["suggestionTypeId"] as? Int ?? 5)
//            }
//        }
    }
    
    func listSearchProduct(searchString: String, type: Int) {
        if KeychainManager.standard.userRoleId == 1 {
            //Artisan Product Catalog
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = ProductCatalogService(client: client).createScene(for: searchString, suggestionType: type)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        }else {
            //Buyer Product Catalog
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = ProductCatalogService(client: client).createScene(forBuyer: searchString, suggestionType: type)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        footer.textAlignment = .center
        footer.textColor = .lightGray
        footer.font = .systemFont(ofSize: 10)
        footer.text = "CRAFT EXCHANGE. An initiative by TATA TRUSTS."
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        let header = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: tableView.frame.size.width-40, height: 60))
        header.textAlignment = .left
        header.textColor = .lightGray
        header.font = .systemFont(ofSize: 16)
        header.numberOfLines = 2
        header.text = "No suggestions for this keyword. Try searching \"saree\", \"fabric\", \"ikat\""
        labelView.addSubview(header)
        return labelView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController?.searchBar.text != nil && searchController?.searchBar.text?.count ?? 0 > 2 && dataArray.count == 0 {
            return 60
        }
        return 0
    }
}

extension SearchTableViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // no-op
    }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchController?.obscuresBackgroundDuringPresentation = false
        return true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if searchText.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return
        } else {
            if searchText.count < 3 {
                return
            }
            self.searchWithSearchString?(searchText)
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearchAction?()
    }
}
