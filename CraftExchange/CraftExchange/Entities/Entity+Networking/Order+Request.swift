//
//  Order+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension Order {
  
    static func getOpenOrders() -> Request<Data, APIError> {
        var str = "order/getOpenOrders"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getOpenOrderDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "order/getOrder/{enquiryId}?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getClosedOrders() -> Request<Data, APIError> {
        var str = "order/getClosedOrders"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getClosedOrderDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "order/getClosedOrder/{enquiryId}?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getArtisanFaultyReview() -> Request<Data, APIError> {
        var str = "enquiry/getAllRefArtisanReview"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getBuyerFaultyReview() -> Request<Data, APIError> {
        var str = "enquiry/getAllRefBuyerReview"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func sendBuyerFaultyReview(orderId: Int, buyerComment: String, multiCheck: String) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["orderId":orderId, "buyerComment":buyerComment, "multiCheck":multiCheck]
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/faultyOrderBuyer/\(orderId)/\(buyerComment)/\(multiCheck)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "sending faulty review failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func sendArtisanReview(orderId: Int, artisanReviewComment: String, multiCheck: String) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["orderId":orderId, "artisanReviewComment":artisanReviewComment, "multiCheck":multiCheck]
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/faultyOrderArisan/\(orderId)/\(artisanReviewComment)/\(multiCheck)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "sending faulty review failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }

    
    public static func getOrderProgress(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getOrderProgress/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get order progress failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func markConcernResolved(orderId: Int) -> Request<Data, APIError> {
        
        let parameters: [String: Any] = ["orderId":orderId]
        var str = "enquiry/isResolved/\(orderId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
           resource: {print(String(data: $0, encoding: .utf8) ?? "marking concern reolved failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func recreateOrder(orderId: Int) -> Request<Data, APIError> {
        var str = "order/recreateOrder?orderId=\(orderId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func orderDispatchAfterRecreation(orderId: Int) -> Request<Data, APIError> {
        var str = "order/orderDispatchAfterRecreation?orderId=\(orderId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
}
