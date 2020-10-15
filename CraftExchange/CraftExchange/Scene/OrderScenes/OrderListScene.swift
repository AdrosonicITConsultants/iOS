//
//  OrderListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension OrderListService {
    func createScene() -> UIViewController {

        let storyboard = UIStoryboard(name: "ArtisanTabbar", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "OrderListController") as! OrderListController

        func setupRefreshActions() {
           syncData()
        }
        
        controller.getDeliveryTimes = {
            let service = EnquiryListService.init(client: self.client)
            service.getDeliveryTime(vc: controller)
        }
        
        controller.getCurrencySigns = {
            let service = EnquiryListService.init(client: self.client)
            service.getCurrency(controller: controller)
        }
        
        func performSync() {
            let service = HomeScreenService.init(client: client)
            service.fetchEnquiryStateData(vc: controller)
            
            if controller.segmentView.selectedSegmentIndex == 0 {
                getOngoingOrders().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        parseEnquiry(json: json, isOngoing: true)
                    }
                }.dispose(in: controller.bag)
            }else {
                getClosedOrders().toLoadingSignal().consumeLoadingState(by: controller).bind(to: controller, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        parseEnquiry(json: json, isOngoing: false)
                    }
                }.dispose(in: controller.bag)
            }
        }
        
        func parseEnquiry(json: [String: Any], isOngoing: Bool) {
            if let array = json["data"] as? [[String: Any]] {
                var i = 0
                var eqArray: [Int] = []
                array.forEach { (dataDict) in
                    i+=1
                    if let prodDict = dataDict["openEnquiriesResponse"] as? [String: Any] {
                        if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                            if let enquiryObj = try? JSONDecoder().decode(Order.self, from: proddata) {
                                DispatchQueue.main.async {
                                    enquiryObj.saveOrUpdate()
                                    enquiryObj.updateAddonDetails(blue: dataDict["isBlue"] as? Bool ?? false, name: dataDict["brandName"] as? String ?? "", moqRejected: dataDict["isMoqRejected"] as? Bool ?? false)
                                    eqArray.append(enquiryObj.entityID)
                                    if i == array.count {
                                        if isOngoing {
                                            controller.ongoingOrders = eqArray
                                        }else {
                                            controller.closedOrders = eqArray
                                        }
                                        controller.endRefresh()
                                    }
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



