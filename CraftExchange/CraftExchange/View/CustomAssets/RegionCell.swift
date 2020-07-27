//
//  RegionCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class RegionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adjectiveLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    var delegate: UIViewController!
    
    func configure(_ cluster: ClusterDetails) {
        titleLabel.text = cluster.clusterDescription ?? ""
        adjectiveLabel.text = cluster.adjective ?? ""
        logoImage.image = UIImage.init(named: cluster.clusterDescription ?? "Saree")
    }
}
