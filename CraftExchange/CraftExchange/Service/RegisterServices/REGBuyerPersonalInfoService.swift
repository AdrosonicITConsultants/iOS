//
//  REGBuyerPersonalInfoService.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class REGBuyerPersonalInfoService: BaseService<[Country]> {
    
    required init() {
        super.init()
    }
    
    override func fetch() -> SafeSignal<[Country]> {
        return Country.getAllCountries().response(using: client).debug()
    }
}
