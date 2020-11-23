//
//  AdminEnquiryListViewController.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm

class AdminEnquiryListViewController: UIViewController {
    @IBOutlet weak var enquiryCountLbl: UILabel!
    @IBOutlet weak var enquirySearchBar: UISearchBar!
    @IBOutlet weak var toggleFilterBtn: UIButton!
    @IBOutlet weak var applyFilterBtn: UIButton!
    
    @IBOutlet weak var clusterBtn: UIButton!
    @IBOutlet weak var artisanBrandTextField: UITextField!
    @IBOutlet weak var buyerBrandTextField: UITextField!
    @IBOutlet weak var availabilityBtn: UIButton!
    @IBOutlet weak var prodCatBtn: UIButton!
    @IBOutlet weak var collectionBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var fromDateBtn: UIButton!
    @IBOutlet weak var toDateBtn: UIButton!
    
    @IBOutlet weak var filterViewHt: NSLayoutConstraint!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var reusableIdentifier = "AdminEnquiryListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reusableIdentifier, bundle: nil), forCellReuseIdentifier: reusableIdentifier)
        tableView.separatorStyle = .none
        filterViewHt.constant = 0
        filterView.isHidden = true
        let app = UIApplication.shared.delegate as? AppDelegate
        enquiryCountLbl.text = "\(app?.countData?.ongoingEnquiries ?? 0)"
    }
    
    @IBAction func toggleFilterSelected(_ sender: Any) {
        if filterViewHt.constant == 0 {
            //Show Filter
            filterViewHt.constant = 410
            filterView.isHidden = false
        }else {
            //Hide Filter
            filterViewHt.constant = 0
            filterView.isHidden = true
        }
    }
    
    @IBAction func applyFilterSelected(_ sender: Any) {
        filterViewHt.constant = 0
        filterView.isHidden = true
    }
    
    @IBAction func clusterSelected(_ sender: Any) {
        
    }
    
    @IBAction func availabilitySelected(_ sender: Any) {
        
    }
    
    @IBAction func prodCatSelected(_ sender: Any) {
        
    }
    
    @IBAction func collectionSelected(_ sender: Any) {
        
    }
    
    @IBAction func datesSelected(_ sender: Any) {
        
    }
    
    @IBAction func fromDateSelected(_ sender: Any) {
        
    }
    
    @IBAction func toDateSelected(_ sender: Any) {
        
    }
}

extension AdminEnquiryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) as! AdminEnquiryListCell
        
        return cell
    }
}
