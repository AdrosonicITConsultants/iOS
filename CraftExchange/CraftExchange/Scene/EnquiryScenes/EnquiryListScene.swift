//
//  EnquiryListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension EnquiryListService {
    func createScene() -> UIViewController {

        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BuyerEnquiryListController") as! BuyerEnquiryListController

        func setupRefreshActions() {
           syncData()
        }
        
        func performSync() {
            let service = HomeScreenService.init(client: client)
            service.fetchEnquiryStateData(vc: controller)
            
            if controller.segmentView.selectedSegmentIndex == 0 {
                getOngoingEnquiries().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        parseEnquiry(json: json, isOngoing: true)
                    }
                }.dispose(in: controller.bag)
            }else {
                getClosedEnquiries().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        parseEnquiry(json: json, isOngoing: false)
                    }
                }.dispose(in: controller.bag)
            }
        }
        
        func parseEnquiry(json: [String: Any], isOngoing: Bool) {
            if let array = json["data"] as? [[String: Any]] {
                array.forEach { (dataDict) in
                    if let prodDict = dataDict["openEnquiriesResponse"] as? [String: Any] {
                        if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                            if let enquiryObj = try? JSONDecoder().decode(Enquiry.self, from: proddata) {
                                DispatchQueue.main.async {
                                    enquiryObj.saveRecord()
                                    enquiryObj.updateAddonDetails(blue: dataDict["isBlue"] as? Bool ?? false, name: dataDict["brandName"] as? String ?? "", moqRejected: dataDict["isMoqRejected"] as? Bool ?? false)
                                    if isOngoing {
                                        if !(controller.ongoingEnquiries.contains(enquiryObj.entityID) ) {
                                            controller.ongoingEnquiries.append(enquiryObj.entityID)
                                        }
                                    }else {
                                        if !(controller.closedEnquiries.contains(enquiryObj.entityID) ) {
                                            controller.closedEnquiries.append(enquiryObj.entityID)
                                        }
                                    }
                                    controller.endRefresh()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func syncData() {
            guard !controller.isEditing else { return }
            guard controller.reachabilityManager?.connection != .unavailable else {
                DispatchQueue.main.async {
                    controller.endRefresh()
                }
                return
            }
            performSync()
        }
        
        controller.viewWillAppear = {
            syncData()
        }
        
        return controller
    }
}



