//
//  ArtisanChangeRequestScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/10/20.
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
    func createArtisanChangeRequestScene(forEnquiry: Int) -> UIViewController {
        let vc = ArtisanChangeRequestController.init(style: .plain)
        vc.enquiryId = forEnquiry
        
        vc.fetchChangeRequest = {
            self.fetchArtisanChangeRquest(vc: vc, enquiryId: forEnquiry)
        }
        
        vc.updateChangeRequest = { (crList, status) in
            let crJson = changeRequest().finalJson(eqId: forEnquiry, list: crList)
            let request = OfflineOrderRequest.init(type: .updateChangeRequest, orderId: forEnquiry, changeRequestStatus: status, changeRequestJson: crJson, submitRatingJson: nil)
            OfflineRequestManager.defaultManager.queueRequest(request)
            vc.showLoading()
        }
        return vc
    }
    
    func fetchArtisanChangeRquest(vc: UIViewController, enquiryId: Int) {
        vc.showLoading()
        self.getChangeRequestDetails(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    if let dataDict = json["data"] as? [String: Any] {
                        if let crDict = dataDict["changeRequest"] as? [String: Any] {
                            if let crData = try? JSONSerialization.data(withJSONObject: crDict, options: .fragmentsAllowed) {
                                if let changeReqObj = try? JSONDecoder().decode(ChangeRequest.self, from: crData) {
                                    DispatchQueue.main.async {
                                        changeReqObj.saveOrUpdate()
                                    }
                                }
                            }
                        }
                        if let crList = dataDict["changeRequestItemList"] as? [[String: Any]] {
                            if let crData = try? JSONSerialization.data(withJSONObject: crList, options: .fragmentsAllowed) {
                                if let changeReqList = try? JSONDecoder().decode([ChangeRequestItem].self, from: crData) {
                                    DispatchQueue.main.async {
                                        changeReqList .forEach { (item) in
                                            item.saveOrUpdate()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                vc.hideLoading()
                if let controller = vc as? ArtisanChangeRequestController {
                    controller.changeRequestObj = ChangeRequest().searchChangeRequest(searchEqId: enquiryId)
                    controller.allChangeRequests = ChangeRequestItem().searchChangeRequestItems(searchId: controller.changeRequestObj?.entityID ?? 0)
                    controller.form.allSections .forEach { (section) in
                        section.reload()
                    }
                }else if let controller = vc as? OrderDetailController {
                    let newVC = OrderDetailsService(client: self.client).createArtisanChangeRequestScene(forEnquiry: enquiryId)
                    controller.navigationController?.pushViewController(newVC, animated: false)
                }
            }
        }.dispose(in: vc.bag)
    }
}
