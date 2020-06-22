//
//  UIView+Extensions.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func dropShadow() {
    layer.shadowColor = UIColor.darkGray.cgColor
    layer.shadowOpacity = 1
    layer.shadowOffset = CGSize.zero
    layer.shadowRadius = 5
  }
  
  func addDashedBorder() {
      let shapeLayer = CAShapeLayer()
      shapeLayer.strokeColor = UIColor.darkGray.cgColor
      shapeLayer.lineWidth = 2
      shapeLayer.lineDashPattern = [5,5]

      let path = CGMutablePath()
      path.addLines(between: [CGPoint(x: 0, y: 0),
                              CGPoint(x: self.frame.width, y: 0)])
      shapeLayer.path = path
      layer.addSublayer(shapeLayer)
  }
}
