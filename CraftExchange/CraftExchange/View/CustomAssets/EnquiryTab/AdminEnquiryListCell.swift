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
}
