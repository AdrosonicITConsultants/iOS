//
//  ChatHeaderView.swift
//  CraftExchange
//
//  Created by Kalyan on 20/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit

protocol ChatHeaderViewProtocol {
    func viewDetailsButtonSelected()
    func escalationButtonSelected()
}

class ChatHeaderView: UIView {

    @IBOutlet var imageButton: RoundedButton!
    @IBOutlet var buyerName: UILabel!
    @IBOutlet var enquiryNumber: UILabel!
    @IBOutlet var CRView: UIButton!
    @IBOutlet var escalationButton: UIButton!
    @IBOutlet var orderStatus: UILabel!
    @IBOutlet var viewDetailsButton: UIButton!
    
    var delegate: ChatHeaderViewProtocol?
    
    @IBAction func viewDetailsButtonSelected(_ sender: Any) {
        delegate?.viewDetailsButtonSelected()
    }
    
    @IBAction func escalationButtonSelected(_ sender: Any) {
        delegate?.escalationButtonSelected()
    }
    
}
