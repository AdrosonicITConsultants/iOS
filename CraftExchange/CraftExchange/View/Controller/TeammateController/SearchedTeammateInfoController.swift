//
//  SearchedTeammateInfoController.swift
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

class SearchedTeammateInfoControllerModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
}

class SearchedTeammateInfoController: UIViewController {
    var viewWillAppear: (() -> ())?
    @IBOutlet weak var whiteLineView: UIView!
    @IBOutlet weak var MobNoValue: UILabel!
    @IBOutlet weak var EmailValue: UILabel!
    @IBOutlet weak var MemberSinceValue: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var MobNoLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var MemberSinceLabel: UILabel!
    @IBOutlet weak var adminPositionLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var InformationLabel: UILabel!
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try! Realm()
    var textValues: AdminTeamUserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
}

