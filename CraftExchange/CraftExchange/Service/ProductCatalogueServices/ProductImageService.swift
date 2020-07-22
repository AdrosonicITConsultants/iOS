//
//  ProductImageService.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import Realm
import RealmSwift

class ProductImageService: BaseService<URL> {
    var productObject: Product!

    convenience init(client: SafeClient, productObject: Product) {
        self.init(client: client)
        self.productObject = productObject
        if let name = productObject.productImages.first?.lable {
            let prodId = productObject.entityID
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }

    override func update(_ object: URL?) {
        super.update(object)
    }

    func fetch() -> Signal<Data, Never> {
        return Product.fetchProductImage(with: productObject.entityID, imageName: productObject.productImages.first?.lable ?? "").response(using: client).debug()
    }
}

