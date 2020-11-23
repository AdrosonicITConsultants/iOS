//
//  MarketingService.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 17/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class MarketingTeammateService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchAdminRoles() -> SafeSignal<Data> {
        return AdminTeammate.getAdminRoles().response(using: client).debug()
    }
    
    func fetchAdminProfile(userId: Int) -> SafeSignal<Data> {
        return AdminTeammate.getAdminProfile(userId: userId).response(using: client).debug()
    }
    
    func fetchAdminTeam(pageNo:Int) -> SafeSignal<Data> {
        return AdminTeammate.getAdminTeam(pageNo: pageNo).response(using: client).debug()
    }
}
