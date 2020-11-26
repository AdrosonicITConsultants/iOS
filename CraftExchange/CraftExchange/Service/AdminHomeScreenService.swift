//
//  AdminHomeScreenService.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminHomeScreenService: BaseService<Data> {

    required init() {
        super.init()
    }

    func fetchAllAdminEnquiryAndOrder() -> SafeSignal<Data> {
        return MarketingCount.getAdminEnquiryAndOrder().response(using: client).debug()
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
    
    func fetchAllClusters() -> SafeSignal<[ClusterDetails]> {
      return ClusterDetails.getAllClusters().response(using: client).debug()
    }
    
    func fetchProductUploadData() -> SafeSignal<Data> {
      return Product.getProductUploadData().response(using: client).debug()
    }
    
    func fetchChangeRequestData() -> SafeSignal<[ChangeRequestType]> {
      return Enquiry.getChangeRequestMetadata().response(using: client).debug()
    }
}
