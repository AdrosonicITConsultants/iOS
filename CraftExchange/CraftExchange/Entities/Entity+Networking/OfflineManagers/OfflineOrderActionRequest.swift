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
}

class OfflineOrderRequest: NSObject, OfflineRequest {
    
    var completion: ((Error?) -> Void)?
    let request: Request<Data, APIError>
    let type: OrderActionType
    let orderId: Int
    let changeRequestStatus: Int?
    /// Initializer with an arbitrary number to demonstrate data persistence
    ///
    /// - Parameter identifier: arbitrary number
    init(type: OrderActionType, orderId: Int, changeRequestStatus: Int?) {
        self.type = type
        self.orderId = orderId
        self.changeRequestStatus = changeRequestStatus
        
        switch type {
        case .toggleOrderChangeRequest:
            self.request = Enquiry.toggleChangeRequest(enquiryId: orderId, isEnabled: changeRequestStatus ?? 0)
        }
        super.init()
    }
    
    /// Dictionary methods are optional for simple use cases, but required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String : Any]) {
        guard let type = dictionary["type"] as? OrderActionType else { return  nil }
        guard let orderId = dictionary["orderId"] as? Int else { return  nil }
        guard let changeRequestStatus = dictionary["changeRequestStatus"] as? Int else { return  nil }
        self.init(type: type, orderId: orderId, changeRequestStatus: changeRequestStatus)
    }
    
    var dictionaryRepresentation: [String : Any]? {
        return ["type" : type.rawValue, "orderId" : orderId , "changeRequestStatus" : changeRequestStatus ?? 0]
    }
    
    func perform(completion: @escaping (Error?) -> Void) {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            let error = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            completion(error)
            return
        }
        client.unsafeResponse(for: request).observe(with: { (response) in
            completion(response.error)
        }).dispose(in: self.bag)
    }
}

