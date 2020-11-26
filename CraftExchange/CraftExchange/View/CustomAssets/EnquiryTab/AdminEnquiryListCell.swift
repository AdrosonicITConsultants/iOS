//
//  AdminEnquiryListCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class AdminEnquiryListCell: UITableViewCell {
    @IBOutlet weak var enquiryCodeLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var prodDetailLabel: UILabel!
    @IBOutlet weak var dateStarted: UILabel!
    @IBOutlet weak var dateUpdated: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var finalStateLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var clusterLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var antaranImage: UIImageView!
    
    override func layoutSubviews() {
       super.layoutSubviews()

       //Your separatorLineHeight with scalefactor
       let separatorLineHeight: CGFloat = 20/UIScreen.main.scale

       let separator = UIView()

       separator.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.size.height - separatorLineHeight,
                            width: self.frame.size.width,
                           height: separatorLineHeight)

       separator.backgroundColor = .black

       self.addSubview(separator)
    }
    
    func configureCell(_ enquiryObj: AdminEnquiry) {
        enquiryCodeLabel.text = enquiryObj.code ?? ""
        availabilityLabel.text = enquiryObj.productStatus == 2 ? "Available in stock" : "Make to order"
        prodDetailLabel.text = enquiryObj.tag ?? enquiryObj.historyTag ?? ""
        dateStarted.text = Date().ttceISOString(isoDate: enquiryObj.dateStarted ?? Date())
        dateUpdated.text = Date().ttceISOString(isoDate: enquiryObj.lastUpdated ?? Date())
        eta.text = enquiryObj.eta ?? "NA"
        stateLabel.text = "\(enquiryObj.currenStageId)"
        brandLabel.text = enquiryObj.buyerBrand
        clusterLabel.text = "\(enquiryObj.artisanBrand ?? "NA"),\(enquiryObj.cluster ?? "NA")"
        costLabel.text = "\(enquiryObj.amount)"
        if enquiryObj.madeWithAntharan == 1 {
            antaranImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        }else {
            antaranImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
        }
        if enquiryObj.productId != 0 || enquiryObj.productHistoryId != 0 {
            finalStateLabel.text = enquiryObj.productStatus == 2 ? "/7" : "/10"
        }else if enquiryObj.customProductId != 0 || enquiryObj.customProductHistoryId != 0 {
            finalStateLabel.text = "/10"
            availabilityLabel.text = "Custom Product"
        }
    }
    
    func configureCell(_ enquiryObj: AdminOrder) {
        enquiryCodeLabel.text = enquiryObj.code ?? ""
        availabilityLabel.text = enquiryObj.productStatus == 2 ? "Available in stock" : "Make to order"
        prodDetailLabel.text = enquiryObj.tag ?? enquiryObj.historyTag ?? ""
        dateStarted.text = Date().ttceISOString(isoDate: enquiryObj.dateStarted ?? Date())
        dateUpdated.text = Date().ttceISOString(isoDate: enquiryObj.lastUpdated ?? Date())
        eta.text = enquiryObj.eta ?? "NA"
        stateLabel.text = "\(enquiryObj.currenStageId)"
        brandLabel.text = enquiryObj.buyerBrand
        clusterLabel.text = "\(enquiryObj.artisanBrand ?? "NA"),\(enquiryObj.cluster ?? "NA")"
        costLabel.text = "\(enquiryObj.amount)"
        if enquiryObj.madeWithAntharan == 1 {
            antaranImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        }else {
            antaranImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
        }
        if enquiryObj.productId != 0 || enquiryObj.productHistoryId != 0 {
            finalStateLabel.text = enquiryObj.productStatus == 2 ? "/7" : "/10"
        }else if enquiryObj.customProductId != 0 || enquiryObj.customProductHistoryId != 0 {
            finalStateLabel.text = "/10"
            availabilityLabel.text = "Custom Product"
        }
    }
    
}
