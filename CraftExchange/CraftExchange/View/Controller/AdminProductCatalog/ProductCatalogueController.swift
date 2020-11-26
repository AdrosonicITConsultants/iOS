//
//  ProductCatalogueController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 26/10/20.
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


class ProductCatalogueController: UIViewController {
    //  @IBOutlet weak var scrollView: UIScrollView!
    let reuseIdentifier = "ProductCatalogueCell"
    @IBOutlet weak var productCatelogueLabel: UILabel!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
   // @IBOutlet weak var activeFilterButton: UIButton!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var categoryFilterButton: RoundedButton!
    @IBOutlet weak var availabilityFilterButton: RoundedButton!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var productSearchBar: UISearchBar!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var segmentView: WMSegment!
    @IBOutlet weak var filterView: UIView!
    
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var allProducts: [CatalogueProduct]?
    var allProductsResults: Results<CatalogueProduct>?
    var viewWillAppear: (() -> ())?
    var clusterFilterValue = "All"
    var availabilityFilterValue = "All"
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBarButtomItem = UIBarButtonItem(customView: self.notificationBarButton())
        navigationItem.rightBarButtonItem = rightBarButtomItem
        categoryFilterButton.borderColour = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        availabilityFilterButton.borderColour = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        categoryLabel.text = "Cluster"
        productSearchBar.placeholder = "search by name, code, brand, category"
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allProducts = []
        if self.segmentView.selectedSegmentIndex == 0 {
            self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
            self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }else {
            self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon",1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
            self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        }
        addTopBorderWithColor(tableView, color: #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1), width: 1)
        //  hideShowFilter(isHidden: true)
        definesPresentationContext = false
        //  self.setupSideMenu(false)
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
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
    
    func addTopBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: objView.frame.size.width, height: width)
        objView.layer.addSublayer(border)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewWillAppear?()
        segmentView.buttonTitles = "Artisan Self Design, Antaran Co design".localized
        segmentView.type = .normal
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        if self.reachabilityManager?.connection == .unavailable {
            
            if self.segmentView.selectedSegmentIndex == 0 {
                self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
                self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            }else {
                self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon",1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
                self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            }
             self.hideLoading()
            
        }else{
            
            if self.segmentView.selectedSegmentIndex == 0 {
                self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
                self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            }else {
                self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon",1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
                self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            }
        }
        checkFilter()
        
        let count = allProducts?.count ?? 0
        self.totalLabel.text = "Total Products: \(count)"
        
       
        self.tableView.reloadData()
    }
    
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        self.allProducts?.removeAll()
        
        viewWillAppear?()
    }
    
    @IBAction func addProductBtnSelected(_ sender: Any) {
        print("Add product selected")
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = UploadProductService(client: client).createScene(productObject: nil)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    @IBAction func categoryFilterBtnselected(_ sender: Any) {
        self.presentClusterInputActionsheet()
        
    }
    
    func presentClusterInputActionsheet(){
        let alert = UIAlertController.init(title: "", message: "Choose", preferredStyle: .actionSheet)
        
        let all = UIAlertAction.init(title: "All", style: .default) { (action) in
            self.clusterFilterValue = "All"
            self.categoryFilterButton.setTitle("All", for: .normal)
        }
        alert.addAction(all)
        
        if let allClusters = realm?.objects(ClusterDetails.self).sorted(byKeyPath: "entityID") {
            
            for cluster in allClusters {
                let change = UIAlertAction.init(title: cluster.clusterDescription, style: .default) { (action) in
                    self.categoryFilterButton.setTitle(cluster.clusterDescription, for: .normal)
                    self.clusterFilterValue = cluster.clusterDescription ?? ""
                }
                alert.addAction(change)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func availabilityFilterBtnSelected(_ sender: Any) {
        presentAvailabilityInputActionsheet()
    }
    
    private func presentAvailabilityInputActionsheet(){
        let alert = UIAlertController.init(title: "", message: "Choose", preferredStyle: .actionSheet)
        
        let all = UIAlertAction.init(title: "All", style: .default) { (action) in
            self.availabilityFilterButton.setTitle("All", for: .normal)
            self.availabilityFilterValue = "All"
        }
        alert.addAction(all)
        
        let madetoOrder = UIAlertAction.init(title: "Made to order", style: .default) { (action) in
            self.availabilityFilterButton.setTitle("Made to order", for: .normal)
            self.availabilityFilterValue = "Made to order"
        }
        alert.addAction(madetoOrder)
        
        let availableInStock = UIAlertAction.init(title: "Available in stock", style: .default) { (action) in
            self.availabilityFilterButton.setTitle("Available in stock", for: .normal)
            self.availabilityFilterValue = "Available in Stock"
        }
        alert.addAction(availableInStock)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func applyFilterBtnSelected(_ sender: Any) {
        checkFilter()
        let count = allProducts?.count ?? 0
        self.totalLabel.text = "Total Products: \(count)"
        self.hideLoading()
        self.tableView.reloadData()
    }
    
    func checkFilter() {
        if self.clusterFilterValue != "All" {
            if self.availabilityFilterValue != "All" {
                if self.segmentView.selectedSegmentIndex == 0 {
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","clusterName",clusterFilterValue ).filter("%K == %@","availability",availabilityFilterValue )
                }else {
                    
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","clusterName",clusterFilterValue ).filter("%K == %@","availability",availabilityFilterValue )
                }
            }else{
                if self.segmentView.selectedSegmentIndex == 0 {
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","clusterName",clusterFilterValue )
                }else {
                    
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","clusterName",clusterFilterValue )
                }
            }
        }else{
            if self.availabilityFilterValue != "All" {
                if self.segmentView.selectedSegmentIndex == 0 {
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","availability",availabilityFilterValue )
                }else {
                    
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 ).filter("%K == %@","availability",availabilityFilterValue )
                }
            }else{
                if self.segmentView.selectedSegmentIndex == 0 {
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 0 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
                }else {
                    self.allProductsResults = realm?.objects(CatalogueProduct.self).filter("%K == %@","isDeleted", 0 ).filter("%K == %@","icon", 1 ).filter("%K == %@","userID",User.loggedIn()?.entityID ?? 0 )
                }
            }
        }
        
        self.allProducts = allProductsResults?.sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
        
        if searchText != "" {
            let query = NSCompoundPredicate(type: .or, subpredicates:
                [NSPredicate(format: "code contains[c] %@",searchText),
                 NSPredicate(format: "name contains[c] %@",searchText), NSPredicate(format: "category contains[c] %@",searchText), NSPredicate(format: "brand contains[c] %@",searchText)])
            
            allProducts = allProductsResults?.filter(query).sorted(byKeyPath: "entityID", ascending: false).compactMap({$0})
            
        }
    }
    
}

extension ProductCatalogueController: UITableViewDataSource, UITableViewDelegate, ProductCatalogueProtocol{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProducts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProductCatalogueCell
        if let obj = allProducts?[indexPath.row] {
            cell.configure(obj)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("*** object ***")
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ProductCatalogService(client: client).createAdminProductDetailScene(forProductId: allProducts?[indexPath.row].entityID, isCustom: false, isRedirect: false, enquiryCode: nil, buyerBrand: nil, enquiryDate: nil, enquiryId: nil)

            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
}

extension ProductCatalogueController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchBar.text ?? ""
       // endRefresh()
         applyBtn.sendActions(for: .touchUpInside)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.text = ""
        searchText = ""
        applyBtn.sendActions(for: .touchUpInside)
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applyBtn.sendActions(for: .touchUpInside)
    }
   
    
}



