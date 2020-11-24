//
//  UploadProductService.swift
//  CraftExchange
//
//  Created by Preety Singh on 29/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import Realm
import RealmSwift

class UploadProductService: BaseService<Data> {
    required init() {
        super.init()
    }
    
    func deleteBuyerCustomProduct(withId: Int) -> SafeSignal<Data> {
      return CustomProduct.deleteCustomProduct(withId: withId).response(using: client).debug()
    }
    
    func deleteArtisanProduct(withId: Int) -> SafeSignal<Data> {
      return Product.deleteArtisanProduct(withId: withId).response(using: client).debug()
    }
    
    func getCustomProductDetails(withId: Int) -> SafeSignal<Data> {
      return CustomProduct.getCustomProductDetails(custProdId: withId).response(using: client).debug()
    }
    
    func getFilteredAllArtisans() -> SafeSignal<Data> {
        return SelectArtisanBrand.getAllArtisans().response(using: client).debug()
    }
}
