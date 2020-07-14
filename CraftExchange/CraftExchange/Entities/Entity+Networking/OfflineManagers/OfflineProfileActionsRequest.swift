//
//  OfflineProfileActionsRequest.swift
//  Craft Exchange
//
//  Created by iOS on 18/02/20.
//  Copyright © 2020 ADROSONIC. All rights reserved.
//

import Foundation
import ReactiveKit

enum ProfileActionType: String {
    case editBuyer
    case editArtisan
    case editArtisanBrand
    case editArtisanBank
}

class OfflineProfileActionsRequest: NSObject, OfflineRequest {
    
    var completion: ((Error?) -> Void)?
    let request: Request<Data, APIError>
    let type: ProfileActionType
    let imageData: (Data,String)?
    let json: [String: Any]?
    let bankJson: [[String: Any]]?
    
    /// Initializer with an arbitrary number to demonstrate data persistence
    ///
    /// - Parameter identifier: arbitrary number
    init(type: ProfileActionType, imageData: (Data,String)?, json: [String: Any]?, bankJson:[[String:Any]]?) {
        self.type = type
        self.imageData = imageData
        self.json = json
        self.bankJson = bankJson
        switch type {
        case .editBuyer:
            self.request = User.updateBuyerProfile(json: json ?? ["":""], imageData: imageData?.0, filename: imageData?.1)
        case .editArtisan:
            self.request = User.updateArtisanProfile(json: json ?? ["":""], imageData: imageData?.0, filename: imageData?.1)
        case .editArtisanBrand:
            self.request = User.updateArtisanBrandDetails(json: json ?? ["":""], imageData: imageData?.0, filename: imageData?.1)
        case .editArtisanBank:
            self.request = User.updateArtisanBankDetails(json: bankJson ?? [["":""]])
        }
        super.init()
    }
    
    /// Dictionary methods are optional for simple use cases, but required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String : Any]) {
        guard let json = dictionary["json"] as? [String: Any] else { return  nil }
        guard let type = dictionary["type"] as? ProfileActionType else { return  nil }
        guard let bankJson = dictionary["bankJson"] as? [[String: Any]] else { return nil }
        guard let imageData = dictionary["imageData"] as? (Data,String) else { return nil }
        self.init(type: type, imageData: imageData, json: json, bankJson: bankJson)
    }
    
    var dictionaryRepresentation: [String : Any]? {
        return ["type" : type.rawValue, "imageData": imageData as Any, "json": json as Any, "bankJson": bankJson as Any]
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
