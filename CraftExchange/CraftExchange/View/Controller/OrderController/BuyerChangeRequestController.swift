//
//  BuyerChangeRequestController.swift
//  CraftExchange
//
//  Created by Preety Singh on 24/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ViewRow

class BuyerChangeRequestController: FormViewController {
    
    var raiseChangeRequest: ((_ changeReqArr:[changeRequest]) -> ())?
    var allChangeRequests: Results<ChangeRequestType>?
    var changeReqArray: [changeRequest]?
    let realm = try? Realm()
    let enquiryId: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        allChangeRequests = realm?.objects(ChangeRequestType.self).sorted(byKeyPath: "entityID")
        changeReqArray = []
        
        let changeReqTypeSection = Section() {
            $0.hidden = "$changeReqTypes == false"
        }

        let changeReqTypeView = LabelRow("changeReqTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Change Request Details".localized
        }
        
        form
        +++ Section()
        <<< CRNoteViewRow() { (row) in
            row.cell.Label1.text = "Please Note:\nChange request may be accepted or rejected subjective to the feasibility of the change by the artisan. If accepted, there may be a change in the final amount and hence the pro forma invoice.".localized
            row.cell.Label2.text = "You can only submit this change request once. Be sure about the change requested before submitting it.".localized
        }
        <<< changeReqTypeView
        +++ changeReqTypeSection
        +++ Section()
        <<< ButtonRow() {
            $0.title = "REQUEST FOR CHANGE"
        }.onCellSelection({ (cell, row) in
            self.changeReqArray?.removeAll()
            self.allChangeRequests?.forEach({ (changeReq) in
                if let row = self.form.rowBy(tag: changeReq.id) as? CRBuyerRow {
                    if row.cell.Tickbtn.image(for: .normal) == UIImage.init(systemName: "checkmark.square.fill") && row.cell.CRTextfield.text?.isNotBlank ?? false {
                        let cr = changeRequest.init(changeRequestId: 0, id: 0, requestItemsId: changeReq.entityID, requestStatus: 0, requestText: row.cell.CRTextfield.text)
                        self.changeReqArray?.append(cr)
                    }
                }
            })
            if self.changeReqArray?.count ?? 0 > 0 {
                self.showChangeRequestBuyerView()
            }
        })
        
        allChangeRequests?.forEach({ (changeReq) in
            changeReqTypeSection <<< CRBuyerRow() {
                $0.cell.height = { 50.0 }
                $0.cell.LabelField.text = changeReq.item
                $0.cell.Tickbtn.tag = changeReq.entityID
                $0.tag = changeReq.id
            }
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ChangeRequestRaised"), object: nil, queue: .main) { (notif) in
            self.hideLoading()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showChangeRequestBuyerView() {
        if let _ = self.view.viewWithTag(134) {
                print("do nothing")
            }else {
            let ht = 220 + ((changeReqArray?.count ?? 0)*35)
            let greyView = UIView.init(frame: self.view.frame)
                greyView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
                greyView.tag = 134
            let initiationView = UIView.init(frame: CGRect.init(x: 0, y: 120, width: self.view.frame.size.width, height: CGFloat(ht)))
                initiationView.backgroundColor = .white
            let label = UILabel.init(frame: CGRect.init(x: 20, y: 20, width: self.view.frame.size.width - 40, height: 45))
            label.text = "Are you sure?".localized
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 20)
                
            let label2 = UILabel.init(frame: CGRect.init(x: 20, y: label.frame.origin.y + label.frame.size.height + 5, width: label.frame.size.width, height: 30))
            label2.text = "You are requesting changes for:".localized
            label2.textAlignment = .center
            label2.font = .systemFont(ofSize: 16)
            
            var start = label2.frame.origin.y + label2.frame.size.height + 5
            changeReqArray?.forEach({ (changeReq) in
                let crTitle = UILabel.init(frame: CGRect.init(x: 20, y: start, width: label.frame.size.width/2, height: 30))
                crTitle.text = " \(ChangeRequestType().searchChangeRequest(searchId: changeReq.requestItemsId)?.item ?? "\(changeReq.requestItemsId)"):"
                crTitle.layer.borderColor = UIColor.lightGray.cgColor
                crTitle.layer.borderWidth = 0.5
                crTitle.font = .systemFont(ofSize: 16)
                
                let crValue = UILabel.init(frame: CGRect.init(x: 20+label.frame.size.width/2, y: start, width: label.frame.size.width/2, height: 30))
                crValue.text = " \(changeReq.requestText ?? "")"
                crValue.textColor = UIColor().CEMustard()
                crValue.layer.borderColor = UIColor.lightGray.cgColor
                crValue.layer.borderWidth = 0.5
                crTitle.font = .systemFont(ofSize: 16)
                
                start = start + 35
                initiationView.addSubview(crTitle)
                initiationView.addSubview(crValue)
            })
                
            let label3 = UILabel.init(frame: CGRect.init(x: 20, y: start, width: label.frame.size.width, height: 60))
            label3.numberOfLines = 3
            label3.font = .systemFont(ofSize: 14)
            label3.text = "This change request may or may not be accepted. You can raise change request if rejected by first discussing with artisan in advance to avoid rejection.".localized
            label3.textAlignment = .center
            
            let cancelBtn = UIButton.init(type: .custom)
            cancelBtn.setTitle("Cancel".localized, for: .normal)
            cancelBtn.addTarget(self, action: #selector(hideChangeRequestBuyerView), for: .touchUpInside)
            cancelBtn.frame = CGRect.init(x: self.view.center.x - 80, y: label3.frame.origin.y + label3.frame.size.height + 10, width: 70, height: 30)
            cancelBtn.setTitleColor(.lightGray, for: .normal)
                
            let okBtn = UIButton.init(type: .custom)
            okBtn.setTitle("Ok".localized, for: .normal)
            okBtn.backgroundColor = UIColor().CEGreen()
            okBtn.addTarget(self, action: #selector(raiseChangeRequestBuyer), for: .touchUpInside)
            okBtn.frame = CGRect.init(x: self.view.center.x + 10, y: cancelBtn.frame.origin.y, width: 50, height: 30)
                
            initiationView.addSubview(label)
            initiationView.addSubview(label2)
            initiationView.addSubview(label3)
            initiationView.addSubview(cancelBtn)
            initiationView.addSubview(okBtn)
            greyView.addSubview(initiationView)
            self.view.addSubview(greyView)
            initiationView.center = self.view.center
            self.view.bringSubviewToFront(greyView)
        }
    }
    
    @objc func hideChangeRequestBuyerView() {
        if let initialView = self.view.viewWithTag(134) {
            self.view.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    @objc func raiseChangeRequestBuyer() {
        if let initialView = self.view.viewWithTag(134) {
            self.view.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
            self.raiseChangeRequest?(changeReqArray ?? [])
        }
    }
}


