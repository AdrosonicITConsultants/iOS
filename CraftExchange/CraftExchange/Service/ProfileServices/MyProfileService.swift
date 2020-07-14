//
//  MyProfileService.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class MyProfileService: BaseService<Data> {

    required init() {
        super.init()
    }

    override func fetch() -> SafeSignal<Data> {
      return User.getProfile().response(using: client).debug()
    }
    
    func fetchAllProductCategory() -> SafeSignal<Data> {
      return ProductCategory.getAllProducts().response(using: client).debug()
    }
    
    func updateArtisanProfile(json: [String: Any]) -> SafeSignal<Data> {
        return User.updateArtisanProfile(json: json).response(using: client).debug()
    }
    
    func updateArtisanBrand(json: [String: Any]) -> SafeSignal<Data> {
        return User.updateArtisanBrandDetails(json: json).response(using: client).debug()
    }
    
    func updateArtisanBank(json: [[String: Any]]) -> SafeSignal<Data> {
        return User.updateArtisanBankDetails(json: json).response(using: client).debug()
    }
    
    func updateBuyerDetails(json: [String: Any], imageData: Data?, filename: String?) -> SafeSignal<Data> {
        return User.updateBuyerProfile(json: json, imageData: imageData, filename: filename).response(using: client).debug()
    }
}
