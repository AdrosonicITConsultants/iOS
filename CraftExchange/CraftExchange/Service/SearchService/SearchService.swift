//
//  SearchService.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class SearchService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    
    func artisanSearch(withString: String) -> SafeSignal<Data> {
        return Product.searchArtisanString(with: withString).response(using: client).debug()
    }
    
    func buyerSearch(withString: String) -> SafeSignal<Data> {
        return Product.searchBuyerString(with: withString).response(using: client).debug()
    }
}
