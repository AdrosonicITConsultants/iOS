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

protocol OpenAttachmentViewProtocol {
    func cancelButtonSelected()
}

class OpenAttachmentView: UIView, WKUIDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var attachementView: WKWebView!
    
    var delegate: OpenAttachmentViewProtocol?
    var attachmentURL: String = ""
    
    @IBAction func cancelButtonSelected(_ sender: Any) {
        delegate?.cancelButtonSelected()
    }
    override func layoutSubviews() {
        attachementView.load(URLRequest(url:URL(string: attachmentURL)!))
    }
}
