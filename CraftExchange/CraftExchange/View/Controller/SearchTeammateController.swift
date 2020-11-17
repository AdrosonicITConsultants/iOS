//
//  SearchTeammateController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 13/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class SearchTeammateControllerModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
}

class SearchTeammateController: UIViewController {
    @IBOutlet weak var btnSearch: RoundedButton!
    @IBOutlet weak var backArrowBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var selectRoleTextField: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var selectRoleLabel: UILabel!
    @IBOutlet weak var SearchTeammateLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UIView!
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try! Realm()
    
    @IBAction func showAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "SearchedTeammateInfoController") as! SearchedTeammateInfoController
        vc1.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc1, animated: true)
        print("SearchTeammateSelected")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
