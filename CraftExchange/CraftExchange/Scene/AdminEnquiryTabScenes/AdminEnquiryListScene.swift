//
//  AdminEnquiryListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension AdminEnquiryListService {
    func createScene() -> UIViewController {
        let storyboard = UIStoryboard(name: "AdminEnquiryTab", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdminEnquiryListViewController") as! AdminEnquiryListViewController
        return controller
    }
}
