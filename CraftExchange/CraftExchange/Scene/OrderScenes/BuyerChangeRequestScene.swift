//
//  BuyerChangeRequestScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension OrderDetailsService {
    func createBuyerChangeRequestScene(forEnquiry: Int) -> UIViewController {
        let vc = BuyerChangeRequestController.init(style: .plain)
        
        vc.raiseChangeRequest = { (crList) in
            let crJson = changeRequest().finalJson(eqId: forEnquiry, list: crList)
            let request = OfflineOrderRequest.init(type: .raiseChangeRequest, orderId: forEnquiry, changeRequestStatus: 0, changeRequestJson: crJson, submitRatingJson: nil)
            OfflineRequestManager.defaultManager.queueRequest(request)
            vc.showLoading()
        }
        return vc
    }
}
