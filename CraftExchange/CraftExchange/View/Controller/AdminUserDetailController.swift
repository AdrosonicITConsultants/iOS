//
//  AdminUserDetailController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 22/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import WMSegmentControl
import Photos

class AdminUserDetailViewModel {
    var viewDidLoad: (() -> Void)?
}

class AdminUserDetailController: UIViewController {
    
    let viewModel = AdminUserDetailViewModel()
    var reachabilityManager = try? Reachability()
    @IBAction func ClusterTexField(_ sender: Any) {
    }
    @IBAction func RatingTextField(_ sender: Any) {
    }
    
    @IBOutlet weak var TopRightImg: UIImageView!
    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var Value: UILabel!
    @IBOutlet weak var Rating: UILabel!
    @IBOutlet weak var Segment: UISegmentedControl!
    @IBOutlet weak var childview: UIView!
    
    private lazy var AdminInfoViewController: AdminGeneralInfo = {
        var viewController = AdminGeneralInfo.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var AdminBrandInfoViewController: AdminBrandDetails = {
        var viewController = AdminBrandDetails.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var AdminBankInfoViewController: AdminBankDetails = {
        var viewController = AdminBankDetails.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    override func viewDidLoad() {
        viewModel.viewDidLoad?()
        let realm = try! Realm()
        
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        if Segment.selectedSegmentIndex == 0 {
            add(asChildViewController: AdminInfoViewController)
            remove(asChildViewController: AdminBrandInfoViewController)
            remove(asChildViewController: AdminBankInfoViewController)
        } else if Segment.selectedSegmentIndex == 1 {
            remove(asChildViewController: AdminInfoViewController)
            add(asChildViewController: AdminBrandInfoViewController)
            remove(asChildViewController: AdminBankInfoViewController)
        }else {
            remove(asChildViewController: AdminInfoViewController)
            remove(asChildViewController: AdminBrandInfoViewController)
            add(asChildViewController: AdminBankInfoViewController)
        }
    }
    
    private func add(asChildViewController viewController: FormViewController) {
        // Add Child View Controller
        addChild(viewController)
        // Add Child View as Subview
        childview.backgroundColor = .white
        childview.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = childview.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    private func remove(asChildViewController viewController: FormViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
}

