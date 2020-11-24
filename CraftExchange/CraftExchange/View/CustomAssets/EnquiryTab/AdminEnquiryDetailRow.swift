//
//  AdminEnquiryDetailRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class AdminEnquiryDetailView: Cell<String>, CellType {
    @IBOutlet weak var enquiryCodeLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var prodDetailLabel: UILabel!
    @IBOutlet weak var dateStarted: UILabel!
    @IBOutlet weak var dateUpdated: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var buyerBrandLabel: UILabel!
    @IBOutlet weak var artisanBrandLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var antaranImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configureCell(_ enquiryObj: AdminEnquiry) {
        enquiryCodeLabel.text = enquiryObj.code ?? ""
        availabilityLabel.text = enquiryObj.productStatus == 2 ? "Available in stock" : "Make to order"
        prodDetailLabel.text = enquiryObj.tag ?? enquiryObj.historyTag ?? ""
        dateStarted.text = Date().ttceISOString(isoDate: enquiryObj.dateStarted ?? Date())
        dateUpdated.text = Date().ttceISOString(isoDate: enquiryObj.lastUpdated ?? Date())
        eta.text = enquiryObj.eta ?? "NA"
        stateLabel.text = "\(enquiryObj.currenStageId)"
        buyerBrandLabel.text = enquiryObj.buyerBrand
        artisanBrandLabel.text = "\(enquiryObj.artisanBrand ?? "NA"),\(enquiryObj.cluster ?? "NA")"
        costLabel.text = "\(enquiryObj.amount)"
        if enquiryObj.madeWithAntharan == 1 {
            antaranImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        }else {
            antaranImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
        }
    }
}

final class AdminEnquiryDetailRow: Row<AdminEnquiryDetailView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AdminEnquiryDetailView>(nibName: "AdminEnquiryDetailRow")
    }
}
