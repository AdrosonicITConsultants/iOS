//
//  HomeScreenService.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class HomeScreenService: BaseService<Data> {

    required init() {
        super.init()
    }

    override func fetch() -> SafeSignal<Data> {
      return User.getProfile().response(using: client).debug()
    }
    
    func fetchAllProductCategory() -> SafeSignal<Data> {
      return ProductCategory.getAllProducts().response(using: client).debug()
    }
    
    func fetchAllCountries() -> SafeSignal<[Country]> {
      return Country.getAllCountries().response(using: client).debug()
    }
    
    func fetchAllArtisanProduct() -> SafeSignal<Data> {
      return Product.getAllArtisanProduct().response(using: client).debug()
    }
    
    func fetchAllProducts() -> SafeSignal<Data> {
      return Product.getAllProducts().response(using: client).debug()
    }
    
    func fetchAllClusters() -> SafeSignal<[ClusterDetails]> {
      return ClusterDetails.getAllClusters().response(using: client).debug()
    }
}
