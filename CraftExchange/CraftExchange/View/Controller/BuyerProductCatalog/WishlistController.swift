//
//  WishlistController.swift
//  CraftExchange
//
//  Created by Preety Singh on 20/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class WishlistViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var removeAllWishlistProducts: (() -> ())?
    var deleteWishlistProduct: ((_ prodId: Int) -> ())?
    var checkEnquiry: ((_ prodId: Int) -> ())?
    var generateNewEnquiry: ((_ prodId: Int) -> ())?
    var openNewEnquiry: ((_ enquiryId: Int) -> ())?
}

class WishlistController: UIViewController {
    
    let reuseIdentifier = "BuyerProductCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allProducts: [Product]?
    let realm = try! Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    lazy var viewModel = WishlistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allProducts = []
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
        let rightButtonItem = UIBarButtonItem.init(title: "Empty wishlist".localized, style: .plain, target: self, action: #selector(deleteAllCustomProduct))
        rightButtonItem.tintColor = .red
        self.navigationItem.rightBarButtonItem = rightButtonItem
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear?()
    }
    
    func endRefresh() {
        self.setData()
        self.tableView.reloadData()
    }
    
    func setData() {
        if let list = Product.getWishlistProducts() {
            allProducts = list.compactMap({$0})
        }
        emptyView.isHidden = allProducts?.count == 0 ? false : true
    }
    
    @objc func deleteAllCustomProduct() {
        self.confirmAction("Warning".localized, "Are you sure you want to remove?".localized, confirmedCallback: { (action) in
            self.viewModel.removeAllWishlistProducts?()
        }) { (action) in
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        reachabilityManager?.whenReachable = nil
        reachabilityManager?.whenUnreachable = nil
        reachabilityManager?.stopNotifier()
        viewModel.viewWillAppear = nil
        applicationEnteredForeground = nil
    }
}

extension WishlistController: WishlistScreenProtocol {
    func removeFromWishlistScreen(prodId: Int) {
        self.viewModel.deleteWishlistProduct?(prodId)
    }
    
    func generateEnquiryForProduct(prodId: Int) {
        self.viewModel.checkEnquiry?(prodId)
        let item = self.navigationItem.rightBarButtonItem
        item?.isEnabled = false
    }
}

extension WishlistController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProducts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = allProducts?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuyerProductCell
        if let prod = Product.getProduct(searchId: product?.entityID ?? 0) {
            cell.configure(prod, byAntaran: prod.madeWithAnthran == 1 ? true : false)
            cell.fromWishlist = true
            cell.deleg = self
            cell.wishlistButton.setImage(UIImage.init(named: "ios-remove from wishlist"), for: .normal)
            cell.viewMoreButton.isHidden = true
            cell.generateEnquiryButton.setTitle("Enquire Now  ", for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("*** object ***")
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ProductCatalogService(client: client).createProdDetailScene(forProduct: allProducts?[indexPath.row])
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
}

extension WishlistController: EnquiryExistsViewProtocol, EnquiryGeneratedViewProtocol {
    func closeButtonSelected() {
        self.view.hideEnquiryGenerateView()
        let item = self.navigationItem.rightBarButtonItem
        item?.isEnabled = true
    }
    
    func viewEnquiryButtonSelected(enquiryId: Int) {
//       goToEnquiry(enquiryId: enquiryId)
        self.view.hideEnquiryGenerateView()
        self.view.hideEnquiryExistsView()
        let item = self.navigationItem.rightBarButtonItem
        item?.isEnabled = true
        self.viewModel.openNewEnquiry?(enquiryId)
    }
    
    func cancelButtonSelected() {
        self.view.hideEnquiryExistsView()
        let item = self.navigationItem.rightBarButtonItem
        item?.isEnabled = true
    }
    
    func viewEnquiryButtonSelected(eqId: Int) {
//        goToEnquiry(enquiryId: eqId)
        self.view.hideEnquiryGenerateView()
        self.view.hideEnquiryExistsView()
        let item = self.navigationItem.rightBarButtonItem
        item?.isEnabled = true
        self.viewModel.openNewEnquiry?(eqId)
    }
    
    func generateEnquiryButtonSelected(prodId: Int) {
        self.viewModel.generateNewEnquiry?(prodId)
        self.view.hideEnquiryExistsView()
    }
}

