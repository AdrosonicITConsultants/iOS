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
            
            getOngoingEnquiries().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        array.forEach { (dataDict) in
                            if let prodDict = dataDict["openEnquiriesResponse"] as? [String: Any] {
                                if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                                    if let enquiryObj = try? JSONDecoder().decode(Enquiry.self, from: proddata) {
                                        DispatchQueue.main.async {
                                            enquiryObj.saveRecord()
                                            enquiryObj.updateAddonDetails(blue: dataDict["isBlue"] as? Bool ?? false, name: dataDict["brandName"] as? String ?? "", moqRejected: dataDict["isMoqRejected"] as? Bool ?? false)
                                            if !(controller.ongoingEnquiries.contains(enquiryObj.entityID) ) {
                                                controller.ongoingEnquiries.append(enquiryObj.entityID)
                                            }
                                            controller.endRefresh()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.dispose(in: controller.bag)
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



