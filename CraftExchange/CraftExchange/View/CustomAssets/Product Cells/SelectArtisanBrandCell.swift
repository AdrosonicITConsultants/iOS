//
//  SelectArtisanBrandCell.swift
//  CraftExchange
//
//  Created by Kalyan on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

protocol SelectArtisanBrandProtocol {
  func SingleAerisancheckBtnSelected(tag: IndexPath)
}


class SelectArtisanBrandCell: UITableViewCell {

    @IBOutlet weak var selectToggleButton: UIButton!
    @IBOutlet weak var weaverID: UILabel!
    @IBOutlet weak var artisanBrand: UILabel!
    @IBOutlet weak var artisanCluster: UILabel!
    var delegate: SelectArtisanBrandProtocol?
    var indexpath: IndexPath!
    
    func configure(_ artisanObj: SelectArtisanBrand) {
        weaverID.text = artisanObj.weaverId ?? "NA"
        artisanBrand.text = artisanObj.brand ?? "NA"
        artisanCluster.text = (artisanObj.cluster ?? "NA") + " " + (artisanObj.state ?? "")
    }
    @IBAction func SingleAerisancheckBtnSelected(_ sender: Any) {
        delegate?.SingleAerisancheckBtnSelected(tag: indexpath)
    }
    
}
