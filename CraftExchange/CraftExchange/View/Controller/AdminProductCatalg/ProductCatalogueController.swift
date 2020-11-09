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

class AdminProductCatalogueViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
}

class ProductCatalogueController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productCatelogueLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var availabilityTextField: UITextField!
    @IBOutlet weak var filterLabel: UILabel!
    
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var productSearchBar: UISearchBar!
    @IBOutlet weak var productSegment: UISegmentedControl!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        productSegment.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        productSegment.setTitleTextAttributes(titleTextAttributes2, for: .selected)
    }
}
