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
    
    func showEnquiryInitiationView() {
        if let _ = self.viewWithTag(123) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("EnquiryInitiationView", owner:
            self, options: nil)?.first as? UIView
            initiationView?.tag = 123
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideEnquiryInitiationView() {
        if let initialView = self.viewWithTag(123) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showEnquiryExistsView(controller: UIViewController, prodName: String, enquiryId: String, prodId: Int) {
        if let _ = self.viewWithTag(124) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("EnquiryExistsView", owner:
            self, options: nil)?.first as? EnquiryExistsView
            initiationView?.enquiryIdLabel.text = "With Enquiry Id \(enquiryId)"
            initiationView?.productLabel.text = prodName
            initiationView?.productId = prodId
            initiationView?.delegate = controller as? EnquiryExistsViewProtocol
            initiationView?.tag = 124
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideEnquiryExistsView() {
        if let initialView = self.viewWithTag(124) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showEnquiryGenerateView(controller: UIViewController, enquiryId: Int, enquiryCode: String) {
        if let _ = self.viewWithTag(125) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("EnquiryGeneratedView", owner:
            self, options: nil)?.first as? EnquiryGeneratedView
            initiationView?.enquiryCodeLabel.text = "Enquiry Id \(enquiryCode)"
            initiationView?.enquiryId = enquiryId
            initiationView?.delegate = controller as? EnquiryGeneratedViewProtocol
            initiationView?.tag = 125
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideEnquiryGenerateView() {
        if let initialView = self.viewWithTag(125) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
}
