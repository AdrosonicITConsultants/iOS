//
//  AdminBuyerUserDetailController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 23/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ImageRow
import ViewRow
import WebKit


class AdminBuyerUserDetailViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    
}

class AdminBuyerUserDetailController: UIViewController {
    
    @IBOutlet weak var BuyerScreenLogo: UIImageView!
    @IBOutlet weak var ChildViewBuyer: UIView!
    @IBOutlet weak var BuyerUserImg: UIImageView!
    @IBOutlet weak var BuyerUserLabel: UILabel!
    @IBOutlet weak var BuyerNumberLabel: UILabel!
    @IBOutlet weak var BuyerRatingLabel: UILabel!
    var reachabilityManager = try? Reachability()
    let realm = try! Realm()
    lazy var viewModel = AdminBuyerUserDetailViewModel()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var AdminBuyerInfoViewController: AdminBuyerInfo = {
            var viewController = AdminBuyerInfo.init()
            self.add(asChildViewController: viewController)
            return viewController
        }()
    }
    
    private func add(asChildViewController viewController: FormViewController) {
        // Add Child View Controller
        addChild(viewController)
        // Add Child View as Subview
        ChildViewBuyer.backgroundColor = .white
        ChildViewBuyer.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = ChildViewBuyer.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    override func viewDidLoad() {
     super.viewDidLoad()
     let rightBarButtomItem1 = UIBarButtonItem(customView: self.notificationBarButton())
     let rightBarButtomItem2 = self.searchBarButton()
     navigationItem.rightBarButtonItems = [rightBarButtomItem1, rightBarButtomItem2]
     self.view.backgroundColor = .black
}
}
