//
//  WishlistService.swift
//  CraftExchange
//
//  Created by Preety Singh on 20/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class WishlistService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchAllWishlistProducts() -> SafeSignal<Data> {
      return Product.getAllProductsInWishlist().response(using: client).debug()
    }
    
    func deleteAllWishlistProducts() -> SafeSignal<Data> {
      return Product.deleteAllProductsFromWishlist().response(using: client).debug()
    }
}
