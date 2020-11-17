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
    @IBOutlet weak var previewPI: WKWebView!
    @IBOutlet weak var oldPIButton: UIButton!
    
    var showOldPI: Bool = false
    var showRaisePI: Bool = false
    var delegate: AcceptedPIViewProtocol?
    var data: String = ""
    var isTIDownload = false
    var isOldPI = false

    override func layoutSubviews() {
        previewPI.loadHTMLString( data, baseURL: nil)
        if showOldPI {
            oldPIButton.isHidden = false
            oldPIButton.setTitle("View Old PI".localized, for: .normal)
        }else if showRaisePI {
            oldPIButton.isHidden = false
            oldPIButton.setTitle("Raise New PI".localized, for: .normal)
        }else {
            oldPIButton.isHidden = true
        }
    }
    
    @IBAction func backButtonSelected(_ sender: Any) {
        delegate?.backButtonSelected()
    }
    
    @IBAction func downloadButtonSelected(_ sender: Any) {
        if isTIDownload {
            delegate?.TIdownloadButtonSelected()
        }else{
            if isOldPI {
                delegate?.downloadButtonSelected(isOld: true)
            }else {
                delegate?.downloadButtonSelected(isOld: false)
            }
        }
        
    }
    
    @IBAction func oldPISelected(_ sender: Any) {
        isOldPI = false
        if showOldPI {
            isOldPI = true
            delegate?.viewOldPI?()
        }
        if showRaisePI {
            delegate?.raiseNewPI?()
        }
    }
}
