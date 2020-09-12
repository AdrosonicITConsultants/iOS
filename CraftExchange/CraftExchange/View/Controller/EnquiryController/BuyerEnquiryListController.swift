//
//  BuyerEnquiryListController.swift
//  CraftExchange
//
//  Created by Preety Singh on 04/09/20.
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

class BuyerEnquiryListController: UIViewController {

    let reuseIdentifier = "BuyerEnquiryCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allEnquiries: [Enquiry]?
    var ongoingEnquiries: [Int] = []
    let realm = try? Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: WMSegment!
    @IBOutlet weak var emptyView: UIView!
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        try? reachabilityManager?.startNotifier()
        allEnquiries = []
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    func endRefresh() {
        allEnquiries = realm?.objects(Enquiry.self).filter("%K IN %@","entityID",ongoingEnquiries ?? [0]).compactMap({$0})
        self.tableView.reloadData()
    }
}

extension BuyerEnquiryListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEnquiries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuyerEnquiryCell
        if let obj = allEnquiries?[indexPath.row] {
            cell.configure(obj)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("*** object ***")
//        let vc = BuyerEnquiryDetailsController.init(style: .plain)
//        vc.enquiryObject = allEnquiries?[indexPath.row]
//        vc.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(vc, animated: true)
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = EnquiryDetailsService(client: client).createEnquiryDetailScene(forEnquiry: allEnquiries?[indexPath.row])
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //170, 39, 92
        return segmentView.selectedSegmentIndex == 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let viewEditAction = UIContextualAction(style: .normal, title:  "Chat".localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
        })
        viewEditAction.image = UIImage.init(named: "chat-icon")
        viewEditAction.backgroundColor = UIColor().CEMagenda()

        return UISwipeActionsConfiguration(actions: [viewEditAction])
    }
}
