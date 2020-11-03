//
//  OpenAttachmentView.swift
//  CraftExchange
//
//  Created by Kalyan on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import WebKit

@objc protocol OpenAttachmentViewProtocol {
    @objc optional func faqCancelButtonSelected()
    @objc optional func cancelButtonSelected()
}

class OpenAttachmentView: UIView, WKUIDelegate {
    
    var fromFaq : Bool = false
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var attachementView: WKWebView!
    
    var delegate: OpenAttachmentViewProtocol?
    var attachmentURL: String = ""
    
    @IBAction func cancelButtonSelected(_ sender: Any) {
        if fromFaq {
            delegate?.faqCancelButtonSelected?()
        }
        else {
            delegate?.cancelButtonSelected?()
        }
    }
    override func layoutSubviews() {
        attachementView.load(URLRequest(url:URL(string: attachmentURL)!))

    }
}
