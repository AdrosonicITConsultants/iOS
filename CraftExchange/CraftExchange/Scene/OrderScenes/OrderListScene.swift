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
        controller.fetchData = {
            let service = HomeScreenService.init(client: self.client)
            service.fetchEnquiryStateData(vc: controller)
        }
        
        controller.getDeliveryTimes = {
            let service = EnquiryListService.init(client: self.client)
            service.getDeliveryTime(vc: controller)
        }
        
        controller.getCurrencySigns = {
            let service = EnquiryListService.init(client: self.client)
            service.getCurrency(controller: controller)
        }
        controller.getReviewAndRatingData = {
            
            self.getArtisanFaultyReview().bind(to: controller, context: .global(qos: .background)) { (_, responseData) in
                do {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ArtisanFaultyOrder].self, from: data) .forEach({ (stage) in
                                stage.saveOrUpdate()
                            })
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
            }.dispose(in: controller.bag)
            
            self.getBuyerFaultyReview().bind(to: controller, context: .global(qos: .background)) { (_, responseData) in
                do {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                            try JSONDecoder().decode([BuyerFaultyOrder].self, from: data) .forEach({ (stage) in
                                stage.saveOrUpdate()
                            })
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
            }.dispose(in: controller.bag)
            
            self.getRatingQuestions().bind(to: controller, context: .global(qos: .background)) { (_, responseData) in
                do {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [String: Any] {
                            if let buyerData = array["buyerQuestions"] as? [String: Any]{
                                if let buyerRatingData = buyerData["ratingQuestions"] as? [[String: Any]] {
                                    let data = try JSONSerialization.data(withJSONObject: buyerRatingData, options: .fragmentsAllowed)
                                    try JSONDecoder().decode([RatingQuestionsBuyer].self, from: data) .forEach({ (stage) in
                                        stage.saveOrUpdate()
                                    })
                                }
                                if let buyerCommentData = buyerData["commentQuestions"] as? [[String: Any]] {
                                    let data = try JSONSerialization.data(withJSONObject: buyerCommentData, options: .fragmentsAllowed)
                                    try JSONDecoder().decode([RatingQuestionsBuyer].self, from: data) .forEach({ (stage) in
                                        stage.saveOrUpdate()
                                    })
                                }
                            }
                            if let artisanData = array["artisanQuestions"] as? [String: Any]{
                                if let artisanRatingData = artisanData["ratingQuestions"] as? [[String: Any]] {
                                    let data = try JSONSerialization.data(withJSONObject: artisanRatingData, options: .fragmentsAllowed)
                                    try JSONDecoder().decode([RatingQuestionsArtisan].self, from: data) .forEach({ (stage) in
                                        stage.saveOrUpdate()
                                    })
                                }
                                if let artisanCommentData = artisanData["commentQuestions"] as? [[String: Any]] {
                                    let data = try JSONSerialization.data(withJSONObject: artisanCommentData, options: .fragmentsAllowed)
                                    try JSONDecoder().decode([RatingQuestionsArtisan].self, from: data) .forEach({ (stage) in
                                        stage.saveOrUpdate()
                                    })
                                }
                            }
                            
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
            }.dispose(in: controller.bag)
            
        }
        
        func performSync() {
            
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
                if array.count > 0 {
                    array.forEach { (dataDict) in
                        i+=1
                        if let prodDict = dataDict["openEnquiriesResponse"] as? [String: Any] {
                            if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                                if let enquiryObj = try? JSONDecoder().decode(Order.self, from: proddata) {
                                    DispatchQueue.main.async {
                                        enquiryObj.saveOrUpdate()
                                        enquiryObj.updateAddonDetails(blue: dataDict["isBlue"] as? Bool ?? false, name: dataDict["brandName"] as? String ?? "", moqRejected: dataDict["isMoqRejected"] as? Bool ?? false, isOpen: isOngoing, userId: User.loggedIn()?.entityID ?? 0 )
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
                }else {
                    DispatchQueue.main.async {
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




