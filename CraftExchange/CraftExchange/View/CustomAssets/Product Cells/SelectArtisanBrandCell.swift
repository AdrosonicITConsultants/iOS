//
//  SelectArtisanBrandCell.swift
//  CraftExchange
//
//  Created by Kalyan on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

class SelectArtisanBrandCell: UITableViewCell {

    @IBOutlet weak var selectToggleButton: UIButton!
    @IBOutlet weak var weaverID: UILabel!
    @IBOutlet weak var artisanBrand: UILabel!
    @IBOutlet weak var artisanCluster: UILabel!
    
    func configure(_ artisanObj: SelectArtisanBrand) {
        weaverID.text = (artisanObj.weaverId ?? "") + " \(artisanObj.entityID)"
        artisanBrand.text = artisanObj.brand ?? "NA"
        artisanCluster.text = (artisanObj.cluster ?? "NA") + ", " + (artisanObj.state ?? "")
    }
    
}
