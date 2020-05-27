//
//  ClusterProductCategory.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ClusterProductCategory: Object, Decodable {

    @objc dynamic var entityID: Int = 0
    @objc dynamic var clusterDetailsId: String?
    @objc dynamic var productCategoryId: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case clusterDetailsId = "cluster_details_id"
        case productCategoryId = "product_category_id"
    }

    convenience required init(from decoder: Decoder) throws {
      self.init()
      let values = try decoder.container(keyedBy: CodingKeys.self)
      entityID = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
      clusterDetailsId = try values.decodeIfPresent(String.self, forKey: .clusterDetailsId)
      productCategoryId = try values.decodeIfPresent(String.self, forKey: .productCategoryId)
    }
}
