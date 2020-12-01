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
    var clusterFilterValue = -1
    var availabilityFilterValue = -1
   // var searchText: String = ""
   // var madeWithAntaran = 0
    var reachedLimit = false
    var pageNo = 1
    var eqArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBarButtomItem = UIBarButtonItem(customView: self.notificationBarButton())
        navigationItem.rightBarButtonItem = rightBarButtomItem
        categoryFilterButton.borderColour = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        availabilityFilterButton.borderColour = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
        categoryLabel.text = "Cluster"
        productSearchBar.placeholder = "search by name, code, brand, category"
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        definesPresentationContext = false
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        productSearchBar.returnKeyType = .search
        totalLabel.text = "Total Products: 0"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        segmentView.buttonTitles = "Artisan Self Design, Antaran Co design".localized
        segmentView.type = .normal
        viewWillAppear?()
        refreshAllCounts()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        self.allProducts?.removeAll()
        self.pageNo = 1
        self.reachedLimit = false
        totalLabel.text = "Total Products: 0"
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
            self.clusterFilterValue = -1
            self.categoryFilterButton.setTitle("All", for: .normal)
        }
        alert.addAction(all)
        
        if let allClusters = realm?.objects(ClusterDetails.self).sorted(byKeyPath: "entityID") {
            
            for cluster in allClusters {
                let change = UIAlertAction.init(title: cluster.clusterDescription, style: .default) { (action) in
                    self.categoryFilterButton.setTitle(cluster.clusterDescription, for: .normal)
                    self.clusterFilterValue = cluster.entityID
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
            self.availabilityFilterValue = -1
        }
        alert.addAction(all)
        
        let madetoOrder = UIAlertAction.init(title: "Made to order", style: .default) { (action) in
            self.availabilityFilterButton.setTitle("Made to order", for: .normal)
            self.availabilityFilterValue = 1
        }
        alert.addAction(madetoOrder)
        
        let availableInStock = UIAlertAction.init(title: "Available in stock", style: .default) { (action) in
            self.availabilityFilterButton.setTitle("Available in stock", for: .normal)
            self.availabilityFilterValue = 2
        }
        alert.addAction(availableInStock)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func applyFilterBtnSelected(_ sender: Any) {
        pageNo = 1
        reachedLimit = false
        productSearchBar.resignFirstResponder()
        eqArray = []
        viewWillAppear?()

    }
    
}

extension ProductCatalogueController: UITableViewDataSource, UITableViewDelegate, ProductCatalogueProtocol{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProducts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProductCatalogueCell
        if let obj = allProducts?[indexPath.row] {
            cell.configure(obj)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          
               if self.allProducts?.count ?? 0 > 0 && self.reachedLimit == false {
                   let lastElement = (allProducts?.count ?? 0) - 1
                   if indexPath.row == lastElement {
                       pageNo += 1
                       self.viewWillAppear?()
                   }
               }
       }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        if allProducts?.count == 1 {
            header.text = " Found \(allProducts?.count ?? 0) item"
        }else if allProducts?.count ?? 0 > 0{
            header.text = " Found \(allProducts?.count ?? 0) items"
        }else {
            header.text = " No Results Found!"
        }
        header.font = .systemFont(ofSize: 15)
        return header
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
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           applyBtn.sendActions(for: .touchUpInside)
       }
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
       }
   
    
}



