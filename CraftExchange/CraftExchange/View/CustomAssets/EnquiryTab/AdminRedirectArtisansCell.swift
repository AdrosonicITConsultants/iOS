//
//  AdminRedirectArtisansCell.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol AdminRedirectArtisansProtocol {
  func checkButtonSelected(tag: IndexPath)
}

class AdminRedirectArtisansCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var clusterName: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    var delegate: AdminRedirectArtisansProtocol?
    var indexpath: IndexPath!
    var ischecked = false
    
    func configure(_ artisanObj: AdminRedirectArtisan?) {
        brandName.text = artisanObj?.artisan?.brand ?? "NA"
        if artisanObj?.artisan?.brand == "" {
            brandName.text = "NA"
        }
        clusterName.text = (artisanObj?.artisan?.cluster ?? "") + " " + (artisanObj?.artisan?.state ?? "")
        rating.text = "\(artisanObj?.artisan?.rating ?? 0.0)"
        
        if artisanObj?.isMailSent == 1{
           statusButton.setImage(UIImage.init(named: "eye-grey"), for: .normal)
            checkButton.isHidden = true
        }else if artisanObj?.artisan?.status == 2 {
            statusButton.setImage(UIImage.init(named: "eye-pink"), for: .normal)
            checkButton.isHidden = true
        }else {
            statusButton.setImage(UIImage.init(named: "eye-white"), for: .normal)
            checkButton.isHidden = false
        }
        checkButton.tag = artisanObj?.artisan?.entityID ?? 0
        
    }
    @IBAction func checkButtonSelected(_ sender: Any) {
        print("check button selected")
        if ischecked {
            ischecked = false
            checkButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        }else{
           ischecked = true
           checkButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
        }
        delegate?.checkButtonSelected(tag: indexpath)
    }
    
}
