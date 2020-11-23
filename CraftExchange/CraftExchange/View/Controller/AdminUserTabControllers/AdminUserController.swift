//
//  AdminUserController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 22/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability
import SpreadsheetView

class AdminUserController: UIViewController {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var header = [String]()
    var reachabilityManager = try? Reachability()
    var viewWillAppear: (() -> ())?
    var loadMetaData: (() -> ())?
    var allUsers: Results<AdminUser>?
    let realm = try! Realm()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var FilterLabel: UILabel!
    @IBOutlet weak var CountLabel: UILabel!
    @IBOutlet weak var ArrangeBtn: UIButton!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var AdminDbSearch: UISearchBar!
    @IBOutlet weak var Cluster: UILabel!
    @IBOutlet weak var AdminUserLabel: UILabel!
    @IBOutlet weak var clusterBtn: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    var pageNo = 1
    var selectedCluster: ClusterDetails?
    var selectedRating = -1.0
    var reachedLimit = false
    var totalCount: Int?
    
    enum Sorting {
        case ascending
        case descending

        var symbol: String {
            switch self {
            case .ascending:
                return "\u{25B2}"
            case .descending:
                return "\u{25BC}"
            }
        }
    }
    var sortedColumn = (column: 0, sorting: Sorting.ascending)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.spreadsheetView.backgroundColor = .black
        
        segmentedControl.setBlackControl()
        header = ["Artisan id", "Name", "Email", "Cluster", "Brand", "Rating", "Date"]
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        AdminDbSearch.delegate = self
        loadMetaData?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
    }
    
    @IBAction func ApplyBtnPressed(_ sender: Any) {
        pageNo = 1
        AdminDbSearch.resignFirstResponder()
        viewWillAppear?()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            CountLabel.text = "Total Artisans: \(totalCount ?? 0)"
            header = ["Artisan id", "Name", "Email", "Cluster", "Brand", "Rating", "Date"]
            clusterBtn.isHidden = false
            Cluster.isHidden = false
        }else {
            CountLabel.text = "Total Buyers: \(totalCount ?? 0)"
            header = ["Name", "Email", "Phone Number", "Brand", "Rating", "Date"]
            clusterBtn.isHidden = true
            Cluster.isHidden = true
            clusterBtn.setTitle(" Cluster", for: .normal)
        }
        ratingBtn.setTitle(" Rating", for: .normal)
        pageNo = 1
        reachedLimit = false
        selectedRating = -1
        selectedCluster = nil
        AdminDbSearch.searchTextField.text = nil
        AdminDbSearch.resignFirstResponder()
        viewWillAppear?()
    }
    
    @IBAction func clusterSelected(_ sender: Any) {
        let button = sender as! UIButton
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.selectedCluster = nil
            button.setTitle("  Cluster", for: .normal)
        }
        alert.addAction(all)
        let catgories = realm.objects(ClusterDetails.self)
        for option in catgories {
            let action = UIAlertAction.init(title: option.clusterDescription ?? "", style: .default) { (action) in
                button.setTitle("  \(option.clusterDescription ?? "")", for: .normal)
                self.selectedCluster = option
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ratingSelected(_ sender: Any) {
        let button = sender as! UIButton
        let ratingArray = ["Greater than 3", "Greater than 6", "Greater than 8"]
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            self.selectedRating = -1
            button.setTitle("  Rating", for: .normal)
        }
        alert.addAction(all)
        for option in ratingArray {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                switch(option) {
                case "Greater than 3":
                    self.selectedRating = 3.0
                    button.setTitle("Rating >= 3", for: .normal)
                case "Greater than 6":
                    self.selectedRating = 6.0
                    button.setTitle("Rating >= 6", for: .normal)
                case "Greater than 8":
                    self.selectedRating = 8.0
                    button.setTitle("Rating >= 8", for: .normal)
                default:
                    self.selectedRating = -1.0
                    button.setTitle("  Rating", for: .normal)
                }
          }
          alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension AdminUserController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        applyBtn.sendActions(for: .touchUpInside)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension AdminUserController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    // MARK: DataSource
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + (allUsers?.count ?? 0)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 120
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 50
        } else {
            return 30
        }
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = header[indexPath.column]

            if case indexPath.column = sortedColumn.column {
                cell.sortArrow.text = sortedColumn.sorting.symbol
            } else {
                cell.sortArrow.text = ""
            }
            cell.setNeedsLayout()
            
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            if segmentedControl.selectedSegmentIndex == 0 {
                switch indexPath.column {
                case 0:
                    cell.label.text = "\(allUsers?[indexPath.row - 1].weaverId ?? "")"
                case 1:
                    cell.label.text = (allUsers?[indexPath.row - 1].firstName ?? "") + (allUsers?[indexPath.row - 1].lastName ?? "")
                case 2:
                    cell.label.text = allUsers?[indexPath.row - 1].email ?? ""
                case 3:
                    cell.label.text = allUsers?[indexPath.row - 1].cluster ?? ""
                case 4:
                    cell.label.text = allUsers?[indexPath.row - 1].brandName ?? ""
                case 5:
                    cell.label.text = "\(allUsers?[indexPath.row - 1].rating ?? 0)"
                case 6:
                    cell.label.text = Date().ttceISOString(isoDate: allUsers?[indexPath.row - 1].dateAdded ?? Date())
                default:
                    cell.label.text = ""
                }
            }else {
                switch indexPath.column {
                case 0:
                    cell.label.text = (allUsers?[indexPath.row - 1].firstName ?? "") + (allUsers?[indexPath.row - 1].lastName ?? "")
                case 1:
                    cell.label.text = allUsers?[indexPath.row - 1].email ?? ""
                case 2:
                    cell.label.text = allUsers?[indexPath.row - 1].mobile ?? ""
                case 3:
                    cell.label.text = allUsers?[indexPath.row - 1].brandName ?? ""
                case 4:
                    cell.label.text = "\(allUsers?[indexPath.row - 1].rating ?? 0)"
                case 5:
                    cell.label.text = Date().ttceISOString(isoDate: allUsers?[indexPath.row - 1].dateAdded ?? Date())
                default:
                    cell.label.text = ""
                }
            }
            
            return cell
        }
    }

    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
            if sortedColumn.column == indexPath.column {
                sortedColumn.sorting = sortedColumn.sorting == .ascending ? .descending : .ascending
            } else {
                sortedColumn = (indexPath.column, .ascending)
            }
            sortTable()
        }else {
            if segmentedControl.selectedSegmentIndex == 0 {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let vc = AdminUserService(client: client).createArtisanProfileScene(forUser: allUsers?[indexPath.row - 1].entityID ?? 0)
                    self.navigationController?.pushViewController(vc, animated: true)
                } catch let error {
                  print("Unable to load view:\n\(error.localizedDescription)")
                }
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let vc = AdminUserService(client: client).createBuyerProfileScene(forUser: allUsers?[indexPath.row - 1].entityID ?? 0)
                    self.navigationController?.pushViewController(vc, animated: true)
                } catch let error {
                  print("Unable to load view:\n\(error.localizedDescription)")
                }
            }
        }
    }
    
    func sortTable() {
        if segmentedControl.selectedSegmentIndex == 0 {
            switch sortedColumn.column {
            case 0:
                allUsers = allUsers?.sorted(byKeyPath: "weaverId", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 1:
                allUsers = allUsers?.sorted(byKeyPath: "firstName", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 2:
                allUsers = allUsers?.sorted(byKeyPath: "email", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 3:
                allUsers = allUsers?.sorted(byKeyPath: "cluster", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 4:
                allUsers = allUsers?.sorted(byKeyPath: "brandName", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 5:
                allUsers = allUsers?.sorted(byKeyPath: "rating", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 6:
                allUsers = allUsers?.sorted(byKeyPath: "dateAdded", ascending: sortedColumn.sorting == .ascending ? true : false)
            default:
                print("do nothing")
            }
        }else {
            switch sortedColumn.column {
            case 0:
                allUsers = allUsers?.sorted(byKeyPath: "firstName", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 1:
                allUsers = allUsers?.sorted(byKeyPath: "email", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 2:
                allUsers = allUsers?.sorted(byKeyPath: "mobile", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 3:
                allUsers = allUsers?.sorted(byKeyPath: "brandName", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 4:
                allUsers = allUsers?.sorted(byKeyPath: "rating", ascending: sortedColumn.sorting == .ascending ? true : false)
            case 5:
                allUsers = allUsers?.sorted(byKeyPath: "dateAdded", ascending: sortedColumn.sorting == .ascending ? true : false)
            default:
                print("do nothing")
            }
        }
        
        spreadsheetView.reloadData()
    }
}

