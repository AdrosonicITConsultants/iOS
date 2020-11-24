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
    var productObject: Product?
    var name: String?
    
    convenience init(client: SafeClient, productObject: Product) {
        self.init(client: client)
        self.productObject = productObject
        if let name = productObject.productImages.first?.lable {
            let prodId = productObject.entityID
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }
    
    convenience init(client: SafeClient, productObject: Product, withName: String) {
        self.init(client: client)
        self.productObject = productObject
        self.name = withName
        let prodId = productObject.entityID
        _object.value = try? Disk.retrieveURL("\(prodId)/\(withName)", from: .caches, as: Data.self)
    }

    func fetch() -> Signal<Data, Never> {
        return Product.fetchProductImage(with: productObject?.entityID ?? 0, imageName: name ?? productObject?.productImages.first?.lable ?? "").response(using: client).debug()
    }
    
    func fetch(withName: String) -> Signal<Data, Never> {
        return Product.fetchProductImage(with: productObject?.entityID ?? 0, imageName: withName).response(using: client).debug()
    }
    
    func fetch(withId: Int, withName: String) -> Signal<Data, Never> {
        return Product.fetchProductImage(with: withId, imageName: withName).response(using: client).debug()
    }
}


class AdminProductImageService: BaseService<URL> {
    var productObject: CatalogueProduct?
    var name: String?
    
    convenience init(client: SafeClient, productObject: CatalogueProduct) {
        self.init(client: client)
        self.productObject = productObject
        if let name = productObject.images{
            let prodId = productObject.entityID
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }
    
    convenience init(client: SafeClient, productObject: CatalogueProduct, withName: String) {
        self.init(client: client)
        self.productObject = productObject
        self.name = withName
        let prodId = productObject.entityID
        _object.value = try? Disk.retrieveURL("\(prodId)/\(withName)", from: .caches, as: Data.self)
    }

    func fetch() -> Signal<Data, Never> {
        return Product.fetchProductImage(with: productObject?.entityID ?? 0, imageName: name ?? productObject?.images ?? "").response(using: client).debug()
    }
    
    func fetch(withName: String) -> Signal<Data, Never> {
        return Product.fetchProductImage(with: productObject?.entityID ?? 0, imageName: withName).response(using: client).debug()
    }
    
    func fetch(withId: Int, withName: String) -> Signal<Data, Never> {
        return Product.fetchProductImage(with: withId, imageName: withName).response(using: client).debug()
    }
}

