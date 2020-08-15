//
//  OfflineProductRequest.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import ReactiveKit

enum ProductRequestType: String {
    case uploadProduct
    case editProduct
    case uploadCustomProd
    case editCustomProd
}


class OfflineProductRequest: NSObject, OfflineRequest {
    
    var completion: ((Error?) -> Void)?
    let request: Request<Data, APIError>
    let type: ProductRequestType
    let imageData: [(String,Data)]?
    let json: [String: Any]?
    
    /// Initializer with an arbitrary number to demonstrate data persistence
    ///
    /// - Parameter identifier: arbitrary number
    init(type: ProductRequestType, imageData: [(String,Data)]?, json: [String: Any]) {
        self.type = type
        self.imageData = imageData
        self.json = json
        switch type {
        case .uploadProduct:
            self.request = Product.uploadProduct(json: json, imageData: imageData ?? [])
        case .editProduct:
            self.request = Product.editProduct(json: json, imageData: imageData ?? [])
        case .uploadCustomProd:
            self.request = Product.uploadCustomProduct(json: json, imageData: imageData ?? [])
        case .editCustomProd:
            self.request = Product.editCustomProduct(json: json, imageData: imageData ?? [])
        }
        super.init()
    }
    
    /// Dictionary methods are optional for simple use cases, but required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String : Any]) {
        guard let json = dictionary["json"] as? [String: Any] else { return  nil }
        guard let type = dictionary["type"] as? ProductRequestType else { return  nil }
        guard let imageData = dictionary["imageData"] as? [(String,Data)] else { return nil }
        self.init(type: type, imageData: imageData, json: json)
    }
    
    var dictionaryRepresentation: [String : Any]? {
        return ["type" : type.rawValue, "imageData": imageData as Any, "json": json as Any]
    }
    
    func perform(completion: @escaping (Error?) -> Void) {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            let error = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            print("\n\nProduct Upload Error 1: \(error.localizedDescription)")
            completion(error)
            return
        }
        client.unsafeResponse(for: request).observe(with: { (response) in
            print("\n\nProduct Upload Error 2: \(response.error?.localizedDescription)")
            completion(response.error)
        }).dispose(in: self.bag)
    }
}
