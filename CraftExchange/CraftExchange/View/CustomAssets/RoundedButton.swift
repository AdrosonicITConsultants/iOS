//
//  RoundedButton.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton: UIButton {
  
  @IBOutlet var roundedButtonView: UIButton!
  
  override init(frame: CGRect) {
   super.init(frame: frame)
   setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {
    roundedButtonView = loadViewFromNib() as! UIButton?
    roundedButtonView.frame = bounds
    
    roundedButtonView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,
                                          UIView.AutoresizingMask.flexibleHeight]
    
    addSubview(roundedButtonView)
    
    // Add our border here and every custom setup
    roundedButtonView.layer.borderWidth = 1
    roundedButtonView.layer.borderColor = UIColor.black.cgColor
    roundedButtonView.layer.cornerRadius = 18
    roundedButtonView.backgroundColor = .black
    roundedButtonView.setTitleColor(.white, for: .normal)
    roundedButtonView.setTitle("", for: .normal)
  }
  
  func loadViewFromNib() -> UIView! {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
    
    return view
  }
}
