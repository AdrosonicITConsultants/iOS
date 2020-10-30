//
//  AdminUserController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 22/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class AdminUserViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
}

class AdminUserController: UIViewController {
    
    let reuseIdentifier = "BuyerProductCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allProducts: [Product]?
    let realm = try! Realm()
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    @IBOutlet weak var FilterLabel: UILabel!
    @IBOutlet weak var Trial: UITableView!
    @IBOutlet weak var CountLabel: UILabel!
    @IBOutlet weak var ArrangeBtn: UIButton!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var AdminDbSearch: UISearchBar!
    @IBOutlet weak var Cluster: UILabel!
    lazy var viewModel = AdminUserViewModel()
    @IBOutlet weak var AdminUserLabel: UILabel!
    
    @IBAction func ApplyBtnPressed(_ sender: Any) {
        print("Kiran")
        //        let storyboard = UIStoryboard(name: "AdminUserDatabase", bundle: nil)
        //        let vc1 = storyboard.instantiateViewController(withIdentifier: "AdminBuyerUserDetailController") as! AdminBuyerUserDetailController
        //        vc1.modalPresentationStyle = .fullScreen
//        let storyboard = UIStoryboard(name: "AdminProductCatalogue", bundle: nil)
//        let vc1 = storyboard.instantiateViewController(withIdentifier: "ProductCatalogueController") as! ProductCatalogueController
//        vc1.modalPresentationStyle = .fullScreen
//        //        self.navigationController?.pushViewController(vc1, animated: true)
//        self.present(vc1, animated: true, completion: nil)
//        
        let storyboard = UIStoryboard(name: "AdminProductCatalogue", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "AdminUploadProductController") as! AdminUploadProductController
        vc1.modalPresentationStyle = .fullScreen
        self.present(vc1, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear?()
    }
    
    func endRefresh() {
        self.Trial.reloadData()
    }
    
    
}

extension AdminUserController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let product = allProducts?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuyerProductCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("*** object ***")
        do {
            
        }catch {
            print(error.localizedDescription)
        }
    }
}

