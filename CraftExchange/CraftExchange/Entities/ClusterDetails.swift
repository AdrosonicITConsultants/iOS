//
//  ClusterDetails.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ClusterDetails: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var clusterDescription: String?
    @objc dynamic var adjective: String?
  
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case clusterDescription = "desc"
        case adjective = "adjective"
    }

    convenience required init(from decoder: Decoder) throws {
      
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        clusterDescription = try? values.decodeIfPresent(String.self, forKey: .clusterDescription)
        adjective = try values.decodeIfPresent(String.self, forKey: .adjective)
    }
}
