//
//  UIColor+Extensions.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    func menuTitleBlue() -> UIColor {
      return colorWith(r: 67, g: 99, b: 210)
    }
    
    func washCareBlue() -> UIColor {
      return colorWith(r: 126, g: 162, b: 207)
    }
    
    func menuSelectorBlue() -> UIColor {
      return colorWith(r: 66, g: 125, b: 239)
    }
    
    func CEGreen() -> UIColor {
      return colorWith(r: 77, g: 157, b: 97)
    }
    
    func customLightGray() -> UIColor {
        return colorWith(r: 185, g: 185, b: 185, a: 21)
    }

    func colorWith(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) -> UIColor {
      return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
}
