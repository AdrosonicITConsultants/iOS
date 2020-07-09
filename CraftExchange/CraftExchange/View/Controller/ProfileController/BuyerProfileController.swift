//
//  BuyerProfileController.swift
//  CraftExchange
//
//  Created by Preety Singh on 09/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import WMSegmentControl

class BuyerProfileController: UIViewController {

    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var segmentControl: WMSegment!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var yellowBgView: UIView!
    
    private lazy var GeneralInfoViewController: BuyerGeneralInfo = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = BuyerGeneralInfo.init()

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var CompanyProfileInfoViewController: BuyerCompanyProfileInfo = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = BuyerCompanyProfileInfo.init()

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var ProfileAddrInfoViewController: BuyerProfileAddrInfo = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = BuyerProfileAddrInfo.init()

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    override func viewDidLoad() {
        yellowBgView.layer.cornerRadius = yellowBgView.bounds.width/2
    }
    override func viewDidAppear(_ animated: Bool) {
        segmentControl.setSelectedIndex(0)
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
    }

    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        childContainerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = childContainerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
}
