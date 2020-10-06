//
//  AcceptedPIView.swift
//  CraftExchange
//
//  Created by Kalyan on 30/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import WebKit

protocol AcceptedPIViewProtocol {
    func backButtonSelected()
    func downloadButtonSelected()
}

class AcceptedPIView: UIView, WKUIDelegate {

    @IBOutlet weak var entityIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    
    var delegate: AcceptedPIViewProtocol?
    var data: String = ""
    
    @IBAction func backButtonSelected(_ sender: Any) {
        delegate?.backButtonSelected()
    }
    @IBAction func downloadButtonSelected(_ sender: Any) {
        delegate?.downloadButtonSelected()
    }
    
    @IBOutlet weak var previewPI: WKWebView!
    
    //    override func didAddSubview(_ subview: UIView) {
    //    //    }
    override func layoutSubviews() {
    previewPI.loadHTMLString( data, baseURL: nil)

    }


}
