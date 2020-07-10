//
//  BuyerProfileController.swift
//  CraftExchange
//
//  Created by Preety Singh on 09/07/20.
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
import WMSegmentControl

class BuyerProfileController: UIViewController {

    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var segmentControl: WMSegment!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var yellowBgView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    private lazy var GeneralInfoViewController: BuyerGeneralInfo = {
        var viewController = BuyerGeneralInfo.init()
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var CompanyProfileInfoViewController: BuyerCompanyProfileInfo = {
        var viewController = BuyerCompanyProfileInfo.init()

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var ProfileAddrInfoViewController: BuyerProfileAddrInfo = {
        var viewController = BuyerProfileAddrInfo.init()

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    override func viewDidLoad() {
        yellowBgView.layer.cornerRadius = yellowBgView.bounds.width/2
        buyerNameLbl.text = "\(User.loggedIn()?.firstName ?? "") \n \(User.loggedIn()?.lastName ?? "")"
        companyName.text = User.loggedIn()?.buyerCompanyDetails?.companyName
        ratingLbl.text = "\(User.loggedIn()?.rating ?? 1) / 5"
    }
    override func viewDidAppear(_ animated: Bool) {
        segmentControl.setSelectedIndex(0)
        segmentControl.sendActions(for: .valueChanged)
    }
    @IBAction func segmentValueChanged(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            add(asChildViewController: GeneralInfoViewController)
            remove(asChildViewController: CompanyProfileInfoViewController)
            remove(asChildViewController: ProfileAddrInfoViewController)
        } else if segmentControl.selectedSegmentIndex == 1 {
            remove(asChildViewController: GeneralInfoViewController)
            add(asChildViewController: CompanyProfileInfoViewController)
            remove(asChildViewController: ProfileAddrInfoViewController)
        }else {
            remove(asChildViewController: GeneralInfoViewController)
            remove(asChildViewController: CompanyProfileInfoViewController)
            add(asChildViewController: ProfileAddrInfoViewController)
        }
    }
    @IBAction func editProfileSelected(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("EnableEditNotification"), object: nil)
        if let constraint = (profileView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 0.0
            profileView.isHidden = true
        }
        if let constraint = (buttonView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 60.0
            buttonView.isHidden = false
            self.view.bringSubviewToFront(buttonView)
        }
        buttonView.backgroundColor = .clear
        segmentControl.backgroundColor = .clear
    }
    
    @IBAction func cancelSelected(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("DisableEditNotification"), object: nil)
        if let constraint = (profileView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 200.0
            profileView.isHidden = false
            self.view.bringSubviewToFront(profileView)
        }
        if let constraint = (buttonView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 0.0
            buttonView.isHidden = true
        }
        buttonView.backgroundColor = .clear
        segmentControl.backgroundColor = .white
    }
    
    @IBAction func saveSelected(_ sender: Any) {
        self.cancelSelected(sender)
        //TODO: Save Edit Profile Request
    }

    private func add(asChildViewController viewController: FormViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        childContainerView.backgroundColor = .white
        childContainerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = childContainerView.bounds
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
