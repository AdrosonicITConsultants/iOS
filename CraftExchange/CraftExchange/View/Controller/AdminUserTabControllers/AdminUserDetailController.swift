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
    var refreshProfile: (() -> Void)?
    var updateRating: ((_ newRating: Float) -> Void)?
    var updateProfileActiveStatus: (() -> Void)?
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
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var Segment: UISegmentedControl!
    @IBOutlet weak var childview: UIView!
    var userObject: User?
    
    private lazy var AdminInfoViewController: AdminGeneralInfo = {
        var viewController = AdminGeneralInfo.init()
        viewController.userObject = userObject
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var AdminBrandInfoViewController: AdminBrandDetails = {
        var viewController = AdminBrandDetails.init()
        viewController.userObject = userObject
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var AdminBankInfoViewController: AdminBankDetails = {
        var viewController = AdminBankDetails.init()
        viewController.userObject = userObject
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        viewModel.viewDidLoad?()
        Segment.setBlackControl()
        self.viewModel.refreshProfile?()
        self.setupUser()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("UserProfileReceived"), object: nil, queue: .main) { (notif) in
            self.viewModel.refreshProfile?()
            self.Segment.selectedSegmentIndex = 0
            self.Segment.sendActions(for: .valueChanged)
            self.setupUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var _: AdminGeneralInfo = {
             let viewController = AdminGeneralInfo.init()
             viewController.userObject = userObject
             self.add(asChildViewController: viewController)
             return viewController
        }()
    }
    
    func setupUser() {
        self.Username.text = "\(self.userObject?.firstName ?? "") \(self.userObject?.lastName ?? "")"
        self.Value.text = self.userObject?.weaverId ?? ""
        self.ratingBtn.setTitle(" Rating \(self.userObject?.rating ?? 0.0)", for: .normal)
        if let tag = self.userObject?.profilePic, let userId = self.userObject?.entityID, self.userObject?.profilePic != "" {
            if let downloadedImage = try? Disk.retrieve("\(userId)/\(tag)", from: .caches, as: UIImage.self) {
                self.ProfileImg.image = downloadedImage
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = UserProfilePicService.init(client: client)
                    service.fetch(forUser: userId, img: tag).observeNext { (attachment) in
                        DispatchQueue.main.async {
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(userId)/\(tag)")
                            self.ProfileImg.image = UIImage.init(data: attachment)
                        }
                    }.dispose(in: self.bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
        if User.loggedIn()?.refMarketingRoleId == 1 {
            if let rightButtonItem = self.navigationItem.rightBarButtonItem {
                if userObject?.status == 1 {
                    rightButtonItem.image = UIImage.init(systemName: "person.crop.circle.badge.checkmark")
                    rightButtonItem.tintColor = UIColor().CEGreen()
                }else {
                    rightButtonItem.image = UIImage.init(systemName: "person.crop.circle.badge.xmark")
                    rightButtonItem.tintColor = .systemRed
                }
            }else {
                let rightButtonItem = UIBarButtonItem.init(title: "".localized, style: .plain, target: self, action: #selector(editUserActiveStatus))
                if userObject?.status == 1 {
                    rightButtonItem.image = UIImage.init(systemName: "person.crop.circle.badge.checkmark")
                    rightButtonItem.tintColor = UIColor().CEGreen()
                }else {
                    rightButtonItem.image = UIImage.init(systemName: "person.crop.circle.badge.xmark")
                    rightButtonItem.tintColor = .systemRed
                }
                self.navigationItem.rightBarButtonItem = rightButtonItem
            }
        }
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
    
    @IBAction func editRatingSelected(_ sender: Any) {
        self.showRatingSlider(sliderVal: userObject?.rating ?? 0.0)
    }
    
    @objc func editUserActiveStatus(_ sender: Any) {
        self.confirmAction("Are you sure?", "You want to \(userObject?.status == 1 ? "Deactivate" : "Activate") the user", confirmedCallback: { (action) in
            self.viewModel.updateProfileActiveStatus?()
        }) { (action) in
            
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

