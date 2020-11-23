//
//  AdminUserService.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminUserService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getAllUsers(clusterId: Int, pageNo: Int, rating: Int, roleId: Int, searchStr: String, sortBy: String, sortType: String) -> SafeSignal<Data> {
        return AdminUser.getUsers(clusterId: clusterId, pageNo: pageNo, rating: rating, roleId: roleId, searchStr: searchStr, sortBy: sortBy, sortType: sortType).response(using: client).debug()
    }
    
    func fetchUserProfile(userId: Int) -> SafeSignal<Data> {
        return AdminUser.getUserProfile(userId: userId).response(using: client).debug()
    }
    
    func updateUserRating(userId: Int, rating: Float) -> SafeSignal<Data> {
        return AdminUser.editUserRating(userId: userId, rating: rating).response(using: client).debug()
    }
}
