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

enum ListOption {
    case OngoingEnquiries
    case ClosedEnquiries
    case OngoingOrders
    case CompletedOrders
    case ClosedOrders
}

class AdminEnquiryListViewController: UIViewController {
    @IBOutlet weak var pageTitleLbl: UILabel!
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
    
    var listType: ListOption?
//    var isIncompleteClosed = false
    
    var reusableIdentifier = "AdminEnquiryListCell"
    var viewWillAppear: (()->())?
    var reachedLimit = false
    var allEnquiries: Results<AdminEnquiry>?
    var allOrders: Results<AdminOrder>?
    
    var pageNo = 1
    var selectedCluster: ClusterDetails?
    var selectedAvailability: Int = -1
    var selectedProdCat: ProductCategory?
    var selectedCollection: Int = -1
    var fromDate: Date?
    var toDate: Date?
    var eqArray: [Int] = []
    
    let realm = try? Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reusableIdentifier, bundle: nil), forCellReuseIdentifier: reusableIdentifier)
        tableView.separatorStyle = .none
        filterViewHt.constant = 0
        filterView.isHidden = true
        enquirySearchBar.returnKeyType = .search
        enquirySearchBar.delegate = self
        if let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) {
            self.fromDate = fromDate
            self.toDate = Date()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
        refreshAllCounts()
        let app = UIApplication.shared.delegate as? AppDelegate
        switch listType {
        case .OngoingEnquiries:
            pageTitleLbl.text = "Ongoing Enquiries"
            enquiryCountLbl.text = "\(app?.countData?.ongoingEnquiries ?? 0)"
        case .ClosedEnquiries:
            pageTitleLbl.text = "Incomplete & Closed Enquiries"
            enquiryCountLbl.text = "\(app?.countData?.incompleteAndClosedEnquiries ?? 0)"
        case .OngoingOrders:
            pageTitleLbl.text = "Ongoing Orders"
            enquiryCountLbl.text = "\(app?.countData?.ongoingOrders ?? 0)"
        case .ClosedOrders:
            pageTitleLbl.text = "Incomplete & Closed Orders"
            enquiryCountLbl.text = "\(app?.countData?.incompleteAndClosedOrders ?? 0)"
        case .CompletedOrders:
            pageTitleLbl.text = "Completed Orders"
            enquiryCountLbl.text = "\(app?.countData?.orderCompletedSuccessfully ?? 0)"
        case .none:
            pageTitleLbl.text = "Ongoing Enquiries"
            enquiryCountLbl.text = "\(app?.countData?.ongoingEnquiries ?? 0)"
        }
    }
    
    @IBAction func toggleFilterSelected(_ sender: Any) {
        enquirySearchBar.resignFirstResponder()
        artisanBrandTextField.resignFirstResponder()
        buyerBrandTextField.resignFirstResponder()
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
        pageNo = 1
        reachedLimit = false
        enquirySearchBar.resignFirstResponder()
        artisanBrandTextField.resignFirstResponder()
        buyerBrandTextField.resignFirstResponder()
        eqArray = []
        viewWillAppear?()
    }
    
    @IBAction func clusterSelected(_ sender: Any) {
        let button = sender as! UIButton
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.selectedCluster = nil
            button.setTitle("  All", for: .normal)
        }
        alert.addAction(all)
        if let catgories = realm?.objects(ClusterDetails.self) {
            for option in catgories {
                let action = UIAlertAction.init(title: option.clusterDescription ?? "", style: .default) { (action) in
                    button.setTitle("  \(option.clusterDescription ?? "")", for: .normal)
                    self.selectedCluster = option
              }
              alert.addAction(action)
            }
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func availabilitySelected(_ sender: Any) {
        let button = sender as! UIButton
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.selectedAvailability = -1
            button.setTitle("  All", for: .normal)
        }
        alert.addAction(all)
        let options = ["Make to order", "Available in stock"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                button.setTitle("  \(option)", for: .normal)
                switch option {
                case "Make to order":
                    self.selectedAvailability = 1
                case "Available in stock":
                    self.selectedAvailability = 2
                default:
                    self.selectedAvailability = -1
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func prodCatSelected(_ sender: Any) {
        let button = sender as! UIButton
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.selectedCluster = nil
            button.setTitle("  All", for: .normal)
        }
        alert.addAction(all)
        if let catgories = realm?.objects(ProductCategory.self) {
            for option in catgories {
                let action = UIAlertAction.init(title: option.prodCatDescription ?? "", style: .default) { (action) in
                    button.setTitle("  \(option.prodCatDescription ?? "")", for: .normal)
                    self.selectedProdCat = option
              }
              alert.addAction(action)
            }
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func collectionSelected(_ sender: Any) {
        let button = sender as! UIButton
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.selectedCollection = -1
            button.setTitle("  All", for: .normal)
        }
        alert.addAction(all)
        let options = ["Antaran Co Design", "Artisan Self Design"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                button.setTitle("  \(option)", for: .normal)
                switch option {
                case "Antaran Co Design":
                    self.selectedCollection = 1
                case "Artisan Self Design":
                    self.selectedCollection = 0
                default:
                    self.selectedCollection = -1
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func clearPreviousDate() {
        fromDateBtn.setTitle("", for: .normal)
        toDateBtn.setTitle("", for: .normal)
        dateBtn.setTitle("", for: .normal)
        self.fromDate = nil
        self.toDate = nil
    }
    
    @IBAction func datesSelected(_ sender: Any) {
        let button = sender as! UIButton
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let options = ["30 Days", "60 Days", "90 Days"]
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                switch option {
                case "60 Days":
                    if let fromDate = Calendar.current.date(byAdding: .day, value: -60, to: Date()) {
                        self.clearPreviousDate()
                        self.fromDate = fromDate
                        self.toDate = Date()
                    }
                case "90 Days":
                    if let fromDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) {
                        self.clearPreviousDate()
                        self.fromDate = fromDate
                        self.toDate = Date()
                    }
                default:
                    if let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) {
                        self.clearPreviousDate()
                        self.fromDate = fromDate
                        self.toDate = Date()
                    }
                }
                button.setTitle("  \(option)", for: .normal)
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func fromDateSelected(_ sender: Any) {
        showDatePicker(withTag: 301)
    }
    
    @IBAction func toDateSelected(_ sender: Any) {
        showDatePicker(withTag: 302)
    }
}

extension AdminEnquiryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch listType {
        case .OngoingEnquiries, .ClosedEnquiries:
            return allEnquiries?.count ?? 0
        default:
            return allOrders?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch listType {
        case .OngoingEnquiries, .ClosedEnquiries:
            let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) as! AdminEnquiryListCell
            if let obj = allEnquiries?[indexPath.row] {
                cell.configureCell(obj)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) as! AdminEnquiryListCell
            if let obj = allOrders?[indexPath.row] {
                cell.configureCell(obj)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch listType {
        case .OngoingEnquiries, .ClosedEnquiries:
            if self.allEnquiries?.count ?? 0 > 0 && self.reachedLimit == false {
                let lastElement = (allEnquiries?.count ?? 0) - 1
                if indexPath.row == lastElement {
                    pageNo += 1
                    self.viewWillAppear?()
                }
            }
        default:
            if self.allOrders?.count ?? 0 > 0 && self.reachedLimit == false {
                let lastElement = (allOrders?.count ?? 0) - 1
                if indexPath.row == lastElement {
                    pageNo += 1
                    self.viewWillAppear?()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        if allEnquiries?.count == 1 || allOrders?.count == 1 {
            header.text = " Found \(allEnquiries?.count ?? 0) item"
        }else if allEnquiries?.count ?? 0 > 0 || allOrders?.count ?? 0 > 0 {
            header.text = " Found \(allEnquiries?.count ?? allOrders?.count ?? 0) items"
        }else {
            header.text = " No Results Found!"
        }
        header.font = .systemFont(ofSize: 15)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch listType {
        case .OngoingEnquiries, .ClosedEnquiries:
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                if let obj = allEnquiries?[indexPath.row] {
                    let vc = EnquiryDetailsService(client: client).createEnquiryDetailScene(forEnquiry: allEnquiries?[indexPath.row], enquiryId: obj.entityID) as! BuyerEnquiryDetailsController
                    vc.modalPresentationStyle = .fullScreen
                    switch listType {
                    case .ClosedOrders, .CompletedOrders, .ClosedEnquiries:
                        vc.isClosed = true
                    default:
                        vc.isClosed = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }catch {
                print(error.localizedDescription)
            }
        default:
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                if let obj = allOrders?[indexPath.row] {
                    let vc = OrderDetailsService(client: client).createOrderDetailScene(forOrder: obj, enquiryId: obj.entityID) as! OrderDetailController
                    vc.modalPresentationStyle = .fullScreen
                    switch listType {
                    case .ClosedOrders, .CompletedOrders, .ClosedEnquiries:
                        vc.isClosed = true
                    default:
                        vc.isClosed = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension AdminEnquiryListViewController {
    
    func showDatePicker(withTag: Int) {
        let datePicker : UIDatePicker = UIDatePicker()
        let datePickerContainer = UIView()
        datePicker.tag = withTag
        datePickerContainer.frame = CGRect(x: 0, y: self.view.frame.size.height - 300, width: self.view.frame.size.width, height: 300.0)
        datePickerContainer.backgroundColor = .white

        datePicker.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 300)
        datePicker.setDate(Date(), animated: true)
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChangedInDate(sender:)), for: .valueChanged)
        datePickerContainer.addSubview(datePicker)

        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.blue, for: .normal)
        doneButton.addTarget(self, action: #selector(dismissPicker(sender:)), for: .touchUpInside)
        doneButton.frame    = CGRect(x: self.view.frame.size.width - 90, y: 5.0, width: 70.0, height: 20.0)

        datePickerContainer.addSubview(doneButton)
        datePickerContainer.tag = 1111
        self.view.addSubview(datePickerContainer)
    }

    @objc func dateChangedInDate(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        if sender.tag == 301 {
            fromDateBtn.setTitle(dateFormatter.string(from: sender.date), for: .normal)
            fromDate = sender.date
        }else {
            toDateBtn.setTitle(dateFormatter.string(from: sender.date), for: .normal)
            toDate = sender.date
        }
    }
    
    @objc func dismissPicker(sender: UIButton) {
        if let view = self.view.viewWithTag(1111) {
            view.removeFromSuperview()
        }
    }
}

extension AdminEnquiryListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applyFilterBtn.sendActions(for: .touchUpInside)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
