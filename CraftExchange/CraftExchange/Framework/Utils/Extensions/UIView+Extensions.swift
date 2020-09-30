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
    
    func showEnquiryExistsView(controller: UIViewController, prodName: String, enquiryCode: String, enquiryId: Int, prodId: Int) {
        if let _ = self.viewWithTag(124) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("EnquiryExistsView", owner:
                self, options: nil)?.first as? EnquiryExistsView
            initiationView?.enquiryIdLabel.text = "With Enquiry Id \(enquiryCode)"
            initiationView?.productLabel.text = prodName
            initiationView?.productId = prodId
            initiationView?.enquiryId = enquiryId
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
    
    func showAcceptMOQView(controller: UIViewController, getMOQs: GetMOQs) {
        if let _ = self.viewWithTag(126) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("MOQAcceptView", owner:
                self, options: nil)?.first as? MOQAcceptView
            initiationView?.brandClusterText.text = getMOQs.brand! + " from " + getMOQs.clusterName!
            initiationView?.moqText.text = "\(getMOQs.moq!.moq) pcs"
            initiationView?.pricePerUnitText.text = "₹ " + getMOQs.moq!.ppu!
            initiationView?.ETADaysText.text = "\(EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getMOQs.moq!.deliveryTimeId)!.days) days"
            
            initiationView?.delegate = controller as? MOQAcceptViewProtocol
            initiationView?.tag = 126
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    func hideAcceptMOQView() {
        if let initialView = self.viewWithTag(126) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showAcceptedMOQView(controller: UIViewController, getMOQs: GetMOQs) {
        if let _ = self.viewWithTag(127) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("MOQAcceptedView", owner:
                self, options: nil)?.first as? MOQAcceptedView
            initiationView?.brandClusterText.text = getMOQs.brand! + " from " + getMOQs.clusterName!
            initiationView?.moqText.text = "\(getMOQs.moq!.moq) pcs"
            initiationView?.pricePerUnitText.text = "₹ " + getMOQs.moq!.ppu!
            initiationView?.ETADaysText.text = "\(EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getMOQs.moq!.deliveryTimeId)!.days) days"
            
            initiationView?.delegate = controller as? MOQAcceptedViewProtocol
            initiationView?.tag = 127
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    func hideAcceptedMOQView() {
        if let initialView = self.viewWithTag(127) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showPreviewPIView(controller: UIViewController, entityId: String, date: String, data: String) {
        if let _ = self.viewWithTag(128) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("PreviewPIView", owner:
                self, options: nil)?.first as? PreviewPIView
            initiationView?.entityIdLabel.text = "Pro forma invoice for " + entityId
            initiationView?.dateLabel.text = "Date accepted " + date
            initiationView?.data = data
            initiationView?.delegate = controller as? PreviewPIViewProtocol
            initiationView?.tag = 128
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    func hidePreviewPIView() {
        if let initialView = self.viewWithTag(128) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showAcceptedPIView(controller: UIViewController, entityId: String, date: String, data: String) {
        if let _ = self.viewWithTag(129) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("AcceptedPIView", owner:
                self, options: nil)?.first as? AcceptedPIView
            initiationView?.entityIdLabel.text = "Pro forma invoice for " + entityId
            initiationView?.dateLabel.text = "Date accepted " + date
            initiationView?.data = data
            initiationView?.delegate = controller as? AcceptedPIViewProtocol
            initiationView?.tag = 129
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    func hideAcceptedPIView() {
        if let initialView = self.viewWithTag(129) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
}
