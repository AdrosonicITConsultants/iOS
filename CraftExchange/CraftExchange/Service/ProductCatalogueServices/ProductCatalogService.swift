//
//  ProductCatalogService.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class ProductCatalogService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchAllArtisanProduct() -> SafeSignal<Data> {
      return Product.getAllArtisanProduct().response(using: client).debug()
    }

    func fetchAllFilteredArtisan() -> SafeSignal<Data> {
      return User.getFilteredArtisans().response(using: client).debug()
    }
    
    func fetchAllProducts(clusterId: Int) -> SafeSignal<[Product]> {
      return Product.getAllProducts(clusterId: clusterId).response(using: client).debug()
    }
    
    func fetchAllProducts(categoryId: Int) -> SafeSignal<Data> {
      return Product.getAllProducts(productCategoryId: categoryId).response(using: client).debug()
    }
    
    func fetchAllProducts(artisanId: Int) -> SafeSignal<Data> {
      return Product.getAllProducts(artisanId: artisanId).response(using: client).debug()
    }
}