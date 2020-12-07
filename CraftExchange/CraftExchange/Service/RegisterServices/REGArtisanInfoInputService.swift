//
//  REGArtisanInfoInputService.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class REGArtisanInfoInputService: BaseService<[ClusterDetails]> {
    
    required init() {
        super.init()
    }
    
    override func fetch() -> SafeSignal<[ClusterDetails]> {
        return ClusterDetails.getAllClusters().response(using: client).debug()
    }
    
    func fetchProductCategory(forCluster: Int) -> SafeSignal<[ClusterDetails]> {
        return ClusterDetails.getProductsForCluster(clusterId: forCluster).response(using: client).debug()
    }
}
