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

class AdminUserViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
}

class AdminUserController: UIViewController {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var header = [String]()
    var data = [[String]]()
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var allProducts: [Product]?
    let realm = try! Realm()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var FilterLabel: UILabel!
    @IBOutlet weak var CountLabel: UILabel!
    @IBOutlet weak var ArrangeBtn: UIButton!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var AdminDbSearch: UISearchBar!
    @IBOutlet weak var Cluster: UILabel!
    lazy var viewModel = AdminUserViewModel()
    @IBOutlet weak var AdminUserLabel: UILabel!
    
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
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControl.setTitleTextAttributes(titleTextAttributes2, for: .selected)
        header = ["brandname", "artisan id", "name", "email", "cluster", "rating date"]
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear?()
    }
    
    func endRefresh() {
        
    }
    
    @IBAction func ApplyBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AdminProductCatalogue", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "AdminUploadProductController") as! AdminUploadProductController
        vc1.modalPresentationStyle = .fullScreen
        self.present(vc1, animated: true, completion: nil)
    }
}

extension AdminUserController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    // MARK: DataSource
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + 30//data.count
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
            cell.label.text = "text \(indexPath.row - 1)\(indexPath.column)"//data[indexPath.row - 1][indexPath.column]
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
            data.sort {
                let ascending = $0[sortedColumn.column] < $1[sortedColumn.column]
                return sortedColumn.sorting == .ascending ? ascending : !ascending
            }
            spreadsheetView.reloadData()
        }
    }
}

