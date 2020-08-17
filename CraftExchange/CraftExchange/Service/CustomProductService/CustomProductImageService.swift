//
//  CustomProductImageService.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import Realm
import RealmSwift

class CustomProductImageService: BaseService<URL> {
    var productObject: CustomProduct!
    var name: String?
    
    convenience init(client: SafeClient, productObject: CustomProduct) {
        self.init(client: client)
        self.productObject = productObject
        if let name = productObject.productImages.first?.lable {
            let prodId = productObject.entityID
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }
    
    func fetchCustomImage(withName: String?) -> Signal<Data, Never> {
        return CustomProduct.fetchCustomProductImage(with: productObject.entityID, imageName: withName ?? productObject.productImages.first?.lable ?? "").response(using: client).debug()
    }
}


