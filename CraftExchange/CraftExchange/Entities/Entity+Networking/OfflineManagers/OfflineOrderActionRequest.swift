//
//  OfflineOrderActionRequest.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import ReactiveKit

enum OrderActionType: String {
    case toggleOrderChangeRequest
    case raiseChangeRequest
    case updateChangeRequest
    case sendRevisedPIRequest
}

class OfflineOrderRequest: NSObject, OfflineRequest {
    
    var completion: ((Error?) -> Void)?
    let request: Request<Data, APIError>
    let type: OrderActionType
    let orderId: Int
    let changeRequestStatus: Int?
    let changeRequestJson: [String: Any]?
    /// Initializer with an arbitrary number to demonstrate data persistence
    ///
    /// - Parameter identifier: arbitrary number
    init(type: OrderActionType, orderId: Int, changeRequestStatus: Int?, changeRequestJson: [String: Any]?) {
        self.type = type
        self.orderId = orderId
        self.changeRequestStatus = changeRequestStatus
        self.changeRequestJson = changeRequestJson
        
        switch type {
        case .toggleOrderChangeRequest:
            self.request = Enquiry.toggleChangeRequest(enquiryId: orderId, isEnabled: changeRequestStatus ?? 0)
        case .raiseChangeRequest:
            self.request = Enquiry.raiseChangeRequest(crJson: changeRequestJson ?? [:])
        case .updateChangeRequest:
            self.request = Enquiry.updateChangeRequest(crJson: changeRequestJson ?? [:], status: changeRequestStatus ?? 0)
        case .sendRevisedPIRequest:
            self.request = Enquiry.sendRevisedPI(enquiryId: orderId, parameters: changeRequestJson ?? [:])
        }
        super.init()
    }
    
    /// Dictionary methods are optional for simple use cases, but required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String : Any]) {
        guard let type = dictionary["type"] as? OrderActionType else { return  nil }
        guard let orderId = dictionary["orderId"] as? Int else { return  nil }
        guard let changeRequestStatus = dictionary["changeRequestStatus"] as? Int else { return  nil }
        guard let changeRequestJson = dictionary["changeRequestJson"] as? [String: Any] else { return  nil }
        self.init(type: type, orderId: orderId, changeRequestStatus: changeRequestStatus, changeRequestJson: changeRequestJson)
    }
    
    var dictionaryRepresentation: [String : Any]? {
        return ["type" : type.rawValue, "orderId" : orderId , "changeRequestStatus" : changeRequestStatus ?? 0, "changeRequestJson" : changeRequestJson as Any]
    }
    
    func perform(completion: @escaping (Error?) -> Void) {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            let error = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            completion(error)
            return
        }
        client.unsafeResponse(for: request).observe(with: { (response) in
            if self.type == .raiseChangeRequest && response.error == nil {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeRequestRaised"), object: nil)
                }
            }else if self.type == .updateChangeRequest && response.error == nil {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeRequestUpdated"), object: nil)
                }
            }else if self.type == .sendRevisedPIRequest && response.error == nil {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIRevised"), object: nil)
                }
            }
            completion(response.error)
        }).dispose(in: self.bag)
    }
}

