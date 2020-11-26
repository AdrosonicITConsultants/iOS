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
    
    func CEMagenda() -> UIColor {
        return colorWith(r: 170, g: 39, b: 72)
    }
    
    func CEMustard() -> UIColor {
        return colorWith(r: 228, g: 175, b: 107)
    }
    
    func customLightGray() -> UIColor {
        return colorWith(r: 185, g: 185, b: 185, a: 21)
    }
    
    func EQBlueBg() -> UIColor {
        return colorWith(r: 226, g: 246, b: 254)
    }
    
    func EQBlueText() -> UIColor {
        return colorWith(r: 88, g: 158, b: 188)
    }
    
    func EQGreenBg() -> UIColor {
        return colorWith(r: 249, g: 255, b: 225)
    }
    
    func EQGreenText() -> UIColor {
        return colorWith(r: 122, g: 134, b: 73)
    }
    
    func EQPurpleBg() -> UIColor {
        return colorWith(r: 237, g: 240, b: 254)
    }
    
    func EQPurpleText() -> UIColor {
        return colorWith(r: 130, g: 147, b: 248)
    }
    
    func EQBrownBg() -> UIColor {
        return colorWith(r: 253, g: 245, b: 238)
    }
    
    func EQBrownText() -> UIColor {
        return colorWith(r: 190, g: 144, b: 103)
    }
    
    func EQPinkBg() -> UIColor {
        return colorWith(r: 247, g: 221, b: 239)
    }
    
    func EQPinkText() -> UIColor {
        return colorWith(r: 199, g: 71, b: 147)
    }

    func colorWith(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) -> UIColor {
      return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
}
