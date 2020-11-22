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
    var refreshProfile: (() -> ())?
}

class AdminBuyerUserDetailController: UIViewController {
    
    @IBOutlet weak var BuyerScreenLogo: UIImageView!
    @IBOutlet weak var ChildViewBuyer: UIView!
    @IBOutlet weak var BuyerUserImg: UIImageView!
    @IBOutlet weak var BuyerUserLabel: UILabel!
    @IBOutlet weak var BuyerNumberLabel: UILabel!
    @IBOutlet weak var BuyerRatingLabel: UILabel!
    var reachabilityManager = try? Reachability()
    lazy var viewModel = AdminBuyerUserDetailViewModel()
    var userObject: User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var _: AdminBuyerInfo = {
            let viewController = AdminBuyerInfo.init()
            viewController.userObject = userObject
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
        self.viewModel.viewWillAppear?()
        self.viewModel.refreshProfile?()
        self.setupUser()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("UserProfileReceived"), object: nil, queue: .main) { (notif) in
            self.viewModel.refreshProfile?()
            let viewController = AdminBuyerInfo.init()
            viewController.userObject = self.userObject
            self.add(asChildViewController: viewController)
            self.setupUser()
        }
    }
    func setupUser() {
        self.BuyerUserLabel.text = "\(self.userObject?.firstName ?? "") \(self.userObject?.lastName ?? "")"
        self.BuyerNumberLabel.text = self.userObject?.buyerCompanyDetails.first?.companyName ?? ""
        self.BuyerRatingLabel.text = "\(self.userObject?.rating ?? 0.0)"
        if let tag = self.userObject?.buyerCompanyDetails.first?.logo, let userId = self.userObject?.entityID, self.userObject?.buyerCompanyDetails.first?.logo != "" {
            if let downloadedImage = try? Disk.retrieve("\(userId)/\(tag)", from: .caches, as: UIImage.self) {
                self.BuyerScreenLogo.image = downloadedImage
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = BrandLogoService.init(client: client)
                    service.fetch(forUser: userId, img: tag).observeNext { (attachment) in
                        DispatchQueue.main.async {
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(userId)/\(tag)")
                            self.BuyerScreenLogo.image = UIImage.init(data: attachment)
                        }
                    }.dispose(in: self.bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
