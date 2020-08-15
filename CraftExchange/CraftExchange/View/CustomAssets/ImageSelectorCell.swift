//
//  ImageSelectorCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 29/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol AddImageProtocol {
    func addImageSelected()
    func deleteImageSelected(atIndex: Int)
}

class ImageSelectorCell: UICollectionViewCell {

    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    var delegate: AddImageProtocol?
    
    @IBAction func addProductSelected(_ sender: Any) {
        delegate?.addImageSelected()
    }
    
    @IBAction func deleteProductSelected(_ sender: Any) {
        let btn = sender as! UIButton
        delegate?.deleteImageSelected(atIndex: btn.tag)
    }
}