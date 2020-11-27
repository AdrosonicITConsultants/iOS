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
    @IBOutlet weak var availabilityImage: UIImageView!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var prodDetailLabel: UILabel!
    @IBOutlet weak var dateStarted: UILabel!
    @IBOutlet weak var dateUpdated: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var finalStateLabel: UILabel!
    @IBOutlet weak var buyerBrandLabel: UILabel!
    @IBOutlet weak var artisanBrandLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var antaranImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configureCell(_ enquiryObj: AdminEnquiry) {
        self.isUserInteractionEnabled = false
        enquiryCodeLabel.text = enquiryObj.code ?? ""
        if enquiryObj.productStatus == 2 {
            availabilityLabel.text = "Available in stock"
            availabilityImage.image = UIImage.init(named: "Avlbl n sck white")
        }else {
            availabilityLabel.text = "Make to order"
            availabilityImage.image = UIImage.init(named: "Made to order white")
        }
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
        statusLabel.text = enquiryObj.currenStage ?? ""
        if enquiryObj.productId != 0 || enquiryObj.productHistoryId != 0 {
            finalStateLabel.text = enquiryObj.productStatus == 2 ? "7" : "10"
        }else if enquiryObj.customProductId != 0 || enquiryObj.customProductHistoryId != 0 {
            finalStateLabel.text = "/10"
            availabilityLabel.text = "Custom Product"
            availabilityImage.isHidden = true
        }
    }
    
    func configureCell(_ enquiryObj: AdminOrder) {
        self.isUserInteractionEnabled = false
        enquiryCodeLabel.text = enquiryObj.code ?? ""
        if enquiryObj.productStatus == 2 {
            availabilityLabel.text = "Available in stock"
            availabilityImage.image = UIImage.init(named: "Avlbl n sck white")
        }else {
            availabilityLabel.text = "Make to order"
            availabilityImage.image = UIImage.init(named: "Made to order white")
        }
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
        statusLabel.text = enquiryObj.currenStage ?? ""
        if enquiryObj.productId != 0 || enquiryObj.productHistoryId != 0 {
            finalStateLabel.text = enquiryObj.productStatus == 2 ? "7" : "10"
        }else if enquiryObj.customProductId != 0 || enquiryObj.customProductHistoryId != 0 {
            finalStateLabel.text = "/10"
            availabilityLabel.text = "Custom Product"
            availabilityImage.isHidden = true
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
