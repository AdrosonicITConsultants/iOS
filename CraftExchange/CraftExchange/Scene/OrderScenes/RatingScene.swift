//
//  RatingScene.swift
//  CraftExchange
//
//  Created by Kalyan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit
import Eureka

extension OrderDetailsService {
    //    func createGiveRatingScene(forOrder: Order?, enquiryId: Int) -> UIViewController {
    //
    //        let vc = RaiseConcernController.init(style: .plain)
    //        vc.orderObject = forOrder
    //
    //        vc.viewWillAppear = {
    //            vc.showLoading()
    //}
    //        return vc
    //}
    
    func createProvideRatingScene(forOrder: Order?, enquiryId: Int) -> UIViewController {
        
        let vc = ProvideRatingController.init(style: .plain)
        vc.orderObject = forOrder
        
        vc.viewWillAppear = {
            vc.showLoading()
            self.getRatingResponse(enquiryId: enquiryId).toLoadingSignal().consumeLoadingState(by: vc).bind(to: vc, context: .global(qos: .background)) { _, responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                    if let dataDict = json["data"] as? [String: Any]
                    {
                        DispatchQueue.main.async {
                            vc.isBuyerRatingDone = dataDict["isBuyerRatingDone"] as? Int
                            vc.isArtisanRatingDone = dataDict["isArtisanRatingDone"] as? Int
                            vc.hideLoading()
                            vc.reloadFormData()
                        }
                    }
                    
                }
            }.dispose(in: vc.bag)
            
        }
        vc.sendRating = { (sendRatingarray) in
            
            // let crJson = changeRequest().finalJson(eqId: forEnquiry, list: crList)
            let request = OfflineOrderRequest.init(type: .sendRating, orderId: enquiryId, changeRequestStatus: nil, changeRequestJson: nil, submitRatingJson: sendRatingarray)
            OfflineRequestManager.defaultManager.queueRequest(request)
            vc.showLoading()
            
        }
        
        return vc
    }
}
