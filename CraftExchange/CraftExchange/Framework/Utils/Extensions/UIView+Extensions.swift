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
    layer.shadowColor = UIColor.lightGray.cgColor
    layer.shadowOpacity = 1
    layer.shadowOffset = CGSize.zero
    layer.shadowRadius = 5
  }
    
    func heightForView(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 100
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 15)
        label.text = text

        label.sizeToFit()
        return label.frame.height
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

extension UILabel {

    func addImageWith(name: String, behindText: Bool) {

        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let lFontSize = round(self.font.pointSize * 1.32)
        
        if let image = UIImage(named: name) {
            let lRatio = image.size.width / image.size.height
            attachment.bounds = CGRect(x: 0, y: ((self.font.capHeight - lFontSize) / 2).rounded(), width: lRatio * lFontSize, height: lFontSize)
        }

        let attachmentString = NSAttributedString(attachment: attachment)

        guard let txt = self.text else {
            return
        }

        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}
