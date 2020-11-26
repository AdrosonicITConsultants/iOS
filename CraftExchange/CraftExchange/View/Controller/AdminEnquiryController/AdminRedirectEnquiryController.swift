//
//  AdminRedirectEnquiryController.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability
import WMSegmentControl
import Reachability
import ReactiveKit
import MessageUI
import MobileCoreServices


class AdminRedirectEnquiryController: UIViewController {
    
    let reuseIdentifier = "AdminRedirectEnquiryCell"
    @IBOutlet weak var redirectEnquiriesCount: UILabel!
    @IBOutlet weak var segmentView: WMSegment!
    @IBOutlet weak var oldestFilterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var allRedirectEnquiries: [AdminRedirectEnquiry]?
    var viewWillAppear0: ((_ sortType: String ) -> ())?
    var viewWillAppear1: ((_ sortType: String ) -> ())?
    var viewWillAppear2: ((_ sortType: String ) -> ())?
    var sortTypeValue = "desc"
    var reachedLimit = false
    var pageNo = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allRedirectEnquiries = []
        
        addTopBorderWithColor(tableView, color: #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1), width: 1)
        definesPresentationContext = false
        //  self.setupSideMenu(false)
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
    }
    
    func addTopBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: objView.frame.size.width, height: width)
        objView.layer.addSublayer(border)
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        allRedirectEnquiries?.removeAll()
        self.pageNo = 1
        self.reachedLimit = false
        if self.segmentView.selectedSegmentIndex == 0 {
            viewWillAppear0?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 1 {
            viewWillAppear1?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 2 {
            viewWillAppear2?(sortTypeValue)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.pageNo = 1
        self.reachedLimit = false
        allRedirectEnquiries?.removeAll()
        if self.segmentView.selectedSegmentIndex == 0 {
            viewWillAppear0?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 1 {
            viewWillAppear1?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 2 {
            viewWillAppear2?(sortTypeValue)
        }
        
        segmentView.buttonTitles = "Custom, Faulty, Other".localized
        segmentView.type = .normal
    }
    
    @objc func pullToRefresh() {
        if self.segmentView.selectedSegmentIndex == 0 {
            viewWillAppear0?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 1 {
            viewWillAppear1?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 2 {
            viewWillAppear2?(sortTypeValue)
        }
    }
    
    func endRefresh() {
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        let count = allRedirectEnquiries?.count ?? 0
        self.redirectEnquiriesCount.text = "\(count)"
        if sortTypeValue == "desc" {
            oldestFilterButton.setTitle("Showing newest first", for: .normal)
        }else{
            oldestFilterButton.setTitle("Showing oldest first", for: .normal)
        }
        self.tableView.reloadData()
    }
    
    @IBAction func oldestBtnFilterSelected(_ sender: Any) {
        allRedirectEnquiries?.removeAll()
        self.pageNo = 1
        self.reachedLimit = false
        if sortTypeValue == "desc" {
            sortTypeValue = "asc"
        }else{
            sortTypeValue = "desc"
        }
        
        if self.segmentView.selectedSegmentIndex == 0 {
            viewWillAppear0?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 1 {
            viewWillAppear1?(sortTypeValue)
        }else if self.segmentView.selectedSegmentIndex == 2 {
            viewWillAppear2?(sortTypeValue)
        }
    }
    
    
    
}

extension AdminRedirectEnquiryController: UITableViewDataSource, UITableViewDelegate, ProductCatalogueProtocol{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRedirectEnquiries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AdminRedirectEnquiryCell
        if let obj = allRedirectEnquiries?[indexPath.row] {
            cell.configure(obj)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.allRedirectEnquiries?.count ?? 0 > 0 && self.reachedLimit == false {
            let lastElement = (allRedirectEnquiries?.count ?? 0) - 1
            if indexPath.row == lastElement {
                pageNo += 1
                if self.segmentView.selectedSegmentIndex == 0 {
                    viewWillAppear0?(sortTypeValue)
                }else if self.segmentView.selectedSegmentIndex == 1 {
                    viewWillAppear1?(sortTypeValue)
                }else if self.segmentView.selectedSegmentIndex == 2 {
                    viewWillAppear2?(sortTypeValue)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        if allRedirectEnquiries?.count == 1 {
            header.text = " Found \(allRedirectEnquiries?.count ?? 0) item"
        }else if allRedirectEnquiries?.count ?? 0 > 0 {
            header.text = " Found \(allRedirectEnquiries?.count ?? 0) items"
        }else {
            header.text = " No Results Found!"
        }
        header.font = .systemFont(ofSize: 15)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("*** object ***")
        var isCustom = false
        var isRedirect = false
        if self.segmentView.selectedSegmentIndex == 0 {
            isCustom = true
            isRedirect = true
        }else if self.segmentView.selectedSegmentIndex == 1 {
            isCustom = true
            isRedirect = true
        }else if self.segmentView.selectedSegmentIndex == 2 {
            isCustom = false
            isRedirect = false
        }
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ProductCatalogService(client: client).createAdminProductDetailScene(forProductId: allRedirectEnquiries?[indexPath.row].productId, isCustom: isCustom, isRedirect: isRedirect, enquiryCode: allRedirectEnquiries?[indexPath.row].code, buyerBrand: allRedirectEnquiries?[indexPath.row].companyName, enquiryDate: allRedirectEnquiries?[indexPath.row].date, enquiryId: allRedirectEnquiries?[indexPath.row].entityID)
            
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
}
