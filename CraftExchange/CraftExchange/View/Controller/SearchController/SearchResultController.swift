//
//  SearchResultController.swift
//  CraftExchange
//
//  Created by Preety Singh on 14/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit
import SideMenu
import Reachability
import RealmSwift
import JGProgressHUD

class SearchResultController: UITableViewController {
    var suggestionArray: [[String: Any]]?
    var reachedSearchLimit = false
    var reuseId = "ArtisanProductCell"
    var loadPage = 1
    var refreshSearchResult: ((_ loadPage: Int, _ madeWithAntaran: Int) -> ())?
    var viewWillAppear: (() -> ())?
    var reachabilityManager = try? Reachability()
    var refreshCategory: ((_ catId: Int) -> ())?
    var catId = 0
    var addToWishlist: ((_ prodId: Int) -> ())?
    var removeFromWishlist: ((_ prodId: Int) -> ())?
    var generateEnquiry: ((_ prodId: Int) -> ())?
    var generateNewEnquiry: ((_ prodId: Int) -> ())?
    var showNewEnquiry: ((_ enquiryId: Int) -> ())?
    
    override func viewDidLoad() {
        suggestionArray = []
        if User.loggedIn()?.refRoleId == "1" {
            reuseId = "ArtisanProductCell"
        }else {
            reuseId = "BuyerProductCell"
        }
        tableView.register(UINib.init(nibName: reuseId, bundle: nil), forCellReuseIdentifier: reuseId)
        let rightButtonItem = UIBarButtonItem.init(title: "Filter by Collection".localized, style: .plain, target: self, action: #selector(showCreatorOptions))
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
    }
    
    @objc func showCreatorOptions() {
        let textArray = ["Show Both".localized, "Artisan Self Design Collection".localized,"Antaran Co-Design Collection".localized]
        let alert = UIAlertController.init(title: "Please select".localized, message: "", preferredStyle: .actionSheet)
        for option in textArray {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                if let index = textArray.firstIndex(of: option) {
                    if index == 2 {
                        self.catId = 1
                    }else if index == 1{
                        self.catId = 0
                    }else {
                        self.catId = -1
                    }
                    self.loadPage = 1
                    self.reachedSearchLimit = false
                    self.suggestionArray?.removeAll()
                    self.tableView.reloadData()
                    self.refreshSearchResult?(self.loadPage, self.catId)
                }else {
                    self.catId = 0
                    self.loadPage = 1
                    self.suggestionArray?.removeAll()
                    self.tableView.reloadData()
                    self.refreshSearchResult?(self.loadPage, self.catId)
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension SearchResultController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if User.loggedIn()?.refRoleId == "1" {
            return 120
        }else {
            return 180
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if User.loggedIn()?.refRoleId == "1" {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! ArtisanProductCell
            if let obj = suggestionArray?[indexPath.row] {
                cell.configure(obj)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! BuyerProductCell
            if let obj = suggestionArray?[indexPath.row] {
                cell.configure(obj)
            }
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedSuggestion = suggestionArray?[indexPath.row] {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let service = ProductCatalogService.init(client: client)
                service.showSelectedProduct(for: self, prodId: selectedSuggestion["id"] as? Int ?? 0)
                self.hideLoading()
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        if suggestionArray?.count == 1 {
            header.text = " Found \(suggestionArray?.count ?? 0) item"
        }else if suggestionArray?.count ?? 0 > 0 {
            header.text = " Found \(suggestionArray?.count ?? 0) items"
        }else {
            header.text = " No Results Found!".localized
        }
        header.font = .systemFont(ofSize: 15)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.suggestionArray?.count ?? 0 > 0 && self.reachedSearchLimit == false {
            let lastElement = (suggestionArray?.count ?? 0) - 1
            if indexPath.row == lastElement {
                loadPage += 1
                self.refreshSearchResult?(loadPage, catId)
            }
        }
    }
}

extension SearchResultController: WishlistProtocol{
    func wishlistSelected(prodId: Int) {
        if let selectedSuggestion = suggestionArray?.filter({ (value) -> Bool in
            value["id"] as? Int == prodId
            }).first {
            //add to wishlist Selected
            addToWishlist?(selectedSuggestion["id"] as? Int ?? 0)
        }
    }
    
    func removeFromWishlist(prodId: Int) {
        if let selectedSuggestion = suggestionArray?.filter({ (value) -> Bool in
        value["id"] as? Int == prodId
        }).first {
            //removeFromWishlist
            removeFromWishlist?(selectedSuggestion["id"] as? Int ?? 0)
        }
    }
    
    func loadProduct(prodId: Int) {
        if let selectedSuggestion = suggestionArray?.filter({ (value) -> Bool in
        value["id"] as? Int == prodId
        }).first {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let service = ProductCatalogService.init(client: client)
                service.showSelectedProduct(for: self, prodId: selectedSuggestion["id"] as? Int ?? 0)
                self.hideLoading()
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func generateEnquiryForProduct(prodId: Int) {
        if let selectedSuggestion = suggestionArray?.filter({ (value) -> Bool in
        value["id"] as? Int == prodId
        }).first {
            //generate enquiry
            self.generateEnquiry?(selectedSuggestion["id"] as? Int ?? 0)
        }
    }
}

extension SearchResultController: EnquiryExistsViewProtocol, EnquiryGeneratedViewProtocol {
    func closeButtonSelected() {
        self.view.hideEnquiryGenerateView()
    }
    
    func viewEnquiryButtonSelected(enquiryId: Int) {
        goToEnquiry(enquiryId: enquiryId)
    }
    
    func cancelButtonSelected() {
        self.view.hideEnquiryExistsView()
    }
    
    func viewEnquiryButtonSelected(eqId: Int) {
        goToEnquiry(enquiryId: eqId)
    }
    
    func generateEnquiryButtonSelected(prodId: Int) {
        self.generateNewEnquiry?(prodId)
        self.view.hideEnquiryExistsView()
    }
    
    func goToEnquiry(enquiryId: Int) {
        self.view.hideEnquiryGenerateView()
        self.view.hideEnquiryExistsView()
        self.showNewEnquiry?(enquiryId)
    }
}
