//
//  AdminTabbarController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 06/11/20.
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

class AdminTabbarController: UIViewController {
  
    @IBOutlet weak var redirectEnquiriesView: UIView!
    @IBOutlet weak var escalationsView: UIView!
    @IBOutlet weak var valueLabel1: UILabel!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var redirectEnquiriesLabel: UILabel!
    @IBOutlet weak var escalationsLabel: UILabel!
    @IBOutlet weak var Imgvalue1: UIImageView!
    @IBOutlet weak var Imgvalue2: UIImageView!
    @IBOutlet weak var valueLabel2: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var childContentView: UIView!
    var reachabilityManager = try? Reachability()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let app = UIApplication.shared.delegate as? AppDelegate
        valueLabel1.text = "\(app?.countData?.totalEnquiries ?? 0)"
        valueLabel2.text = "\(app?.countData?.escaltions ?? 0)"
        segment.selectedSegmentIndex = 0
        segment.sendActions(for: .valueChanged)
//        var AdminEnquiryListViewController: AdminEnquiryList = {
//            var viewController = AdminEnquiryList.init()
//            self.add(asChildViewController: viewController)
//            return viewController
//        }()
    }
    override func viewDidLoad() {
        let realm = try! Realm()
        segment.setBlackControl()
        let clickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.redirectEnquiriesCliked))
        self.redirectEnquiriesView.addGestureRecognizer(clickGesture)

        
    }
    @objc func redirectEnquiriesCliked(sender : UITapGestureRecognizer) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = AdminRedirectEnquiryService(client: client).createScene()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
        
    }
    
    private lazy var AdminEnquiryListViewController: AdminEnquiryList = {
       var viewController = AdminEnquiryList.init()
       self.add(asChildViewController: viewController)
       return viewController
    }()
       
   private lazy var AdminOrderListViewController: AdminOrderList = {
       var viewController = AdminOrderList.init()
       self.add(asChildViewController: viewController)
       return viewController
   }()
    
   @IBAction func segmentValueChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            add(asChildViewController: AdminEnquiryListViewController)
            remove(asChildViewController: AdminOrderListViewController)
        } else if segment.selectedSegmentIndex == 1 {
            remove(asChildViewController: AdminEnquiryListViewController)
            add(asChildViewController: AdminOrderListViewController)
        }
    }
    
    private func add(asChildViewController viewController: FormViewController) {
        // Add Child View Controller
        addChild(viewController)
        // Add Child View as Subview
        childContentView.backgroundColor = .white
        childContentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = childContentView.bounds
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
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = AdminEscalationService(client: client).createScene() as! AdminEscalationController
            vc.modalPresentationStyle = .fullScreen
            vc.catType = .Updates
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
}
