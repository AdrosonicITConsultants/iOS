//
//  PreviewPIView.swift
//  CraftExchange
//
//  Created by Kalyan on 30/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import WebKit

protocol PreviewPIViewProtocol {
    func backButtonSelected()
    func downloadButtonSelected()
    func sendButtonClicked()
}

class PreviewPIView: UIView, WKUIDelegate {
    
    @IBOutlet weak var entityIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var delegate: PreviewPIViewProtocol?
    var data: String = ""
    
    @IBAction func backButtonSelected(_ sender: Any) {
        delegate?.backButtonSelected()
    }
    @IBAction func downloadButtonSelected(_ sender: Any) {
        delegate?.downloadButtonSelected()
    }
    @IBAction func sendButtonClicked(_ sender: Any) {
        delegate?.sendButtonClicked()
    }
    
    @IBOutlet weak var previewPI: WKWebView!
    
    //    override func didAddSubview(_ subview: UIView) {
    //    //    }
    override func layoutSubviews() {
    previewPI.loadHTMLString( data, baseURL: nil)

    }
//    override func awakeFromNib() {
//        previewPI.loadHTMLString( data, baseURL: nil)
//    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
