//
//  AdminTeamUserProfile.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
/*

 class AdminTeammate: Object, Decodable {

     @objc dynamic var id: Int = 0
     @objc dynamic var username: String?
     @objc dynamic var role: String?
     @objc dynamic var email: String?
     

     enum CodingKeys: String, CodingKey {
         case id = "id"
         case username = "username"
         case role = "role"
         case email = "email"
     }

     override class func primaryKey() -> String? {
         return "id"
     }

     convenience required init(from decoder: Decoder) throws {
     self.init()
     let values = try decoder.container(keyedBy: CodingKeys.self)
         id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
         username = try? values.decodeIfPresent(String.self, forKey: .username)
         role = try? values.decodeIfPresent(String.self, forKey: .role)
         email = try? values.decodeIfPresent(String.self, forKey: .email)
     }
 }

 */

class AdminTeamUserProfile: Object, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var username: String?
    @objc dynamic var role: String?
    @objc dynamic var email: String?
    @objc dynamic var memberSince: String?
    @objc dynamic var mobile: String?
    @objc dynamic var status: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case role = "role"
        case email = "email"
        case memberSince = "memberSince"
        case mobile = "mobile"
        case status = "status"
    }

    convenience required init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        username = try? values.decodeIfPresent(String.self, forKey: .username)
        role = try? values.decodeIfPresent(String.self, forKey: .role)
        email = try? values.decodeIfPresent(String.self, forKey: .email)
        memberSince = try? values.decodeIfPresent(String.self, forKey: .memberSince)
        mobile = try? values.decodeIfPresent(String.self, forKey: .mobile)
        status = try (values.decodeIfPresent(Int.self, forKey: .status) ?? 0)
    }
    
//    var id: Int?
//    var username: String?
////    var memberSince: String?
//    var role: String?
//    var email: String?
//    var mobile: Int?
//    var status: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case username = "username"
////        case memberSince = "memberSince"
//        case role = "role"
//        case email = "email"
//        case mobile = "mobile"
//        case status = "status"
//    }
//
////    override class func primaryKey() -> String? {
////        return "id"
////    }
//
////    convenience required init(from decoder: Decoder) throws {
////        self.init()
////        let values = try decoder.container(keyedBy: CodingKeys.self)
////            id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
////            username = try? values.decodeIfPresent(String.self, forKey: .username)
////            memberSince = try? values.decodeIfPresent(String.self, forKey: .memberSince)
////            role = try? values.decodeIfPresent(String.self, forKey: .role)
////            email = try? values.decodeIfPresent(String.self, forKey: .email)
////            mobile = try (values.decodeIfPresent(Int.self, forKey: .mobile) ?? 0)
////            status = try (values.decodeIfPresent(Int.self, forKey: .status) ?? 0)
////    }
//
//    init(id: Int? = nil,
//         username: String? = nil,
////         memberSince: String? = nil,
//         role: String? = nil,
//         email: String? = nil,
//         mobile: Int? = nil,
//         status: Int? = nil) {
//        self.id = id
//        self.username = username
////        self.memberSince = memberSince
//        self.role = role
//        self.email = email
//        self.mobile = mobile
//        self.status = status
//    }
//
}
