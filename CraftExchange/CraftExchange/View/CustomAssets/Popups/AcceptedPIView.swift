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

@objc protocol AcceptedPIViewProtocol {
    func backButtonSelected()
    @objc func downloadButtonSelected(isOld: Bool)
    @objc func TIdownloadButtonSelected()
    @objc optional func viewOldPI()
    @objc optional func raiseNewPI()
}

class AcceptedPIView: UIView, WKUIDelegate {

    @IBOutlet weak var entityIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    var isTIDownload = false
    
    var delegate: AcceptedPIViewProtocol?
    var data: String = ""
    
    @IBAction func backButtonSelected(_ sender: Any) {
        delegate?.backButtonSelected()
    }
    @IBAction func downloadButtonSelected(_ sender: Any) {
        if isTIDownload {
            delegate?.TIdownloadButtonSelected()
        }else{
            delegate?.downloadButtonSelected(isOld: false)
        }
    }
    
    @IBOutlet weak var previewPI: WKWebView!
    
    //    override func didAddSubview(_ subview: UIView) {
    //    //    }
    override func layoutSubviews() {
    previewPI.loadHTMLString( data, baseURL: nil)

    }


}
