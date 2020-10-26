//
//  ArtisanChangeRequestController.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/10/20.
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

class ArtisanChangeRequestController: FormViewController {
    
    var updateChangeRequest: ((_ changeReqArr:[changeRequest]) -> ())?
    var fetchChangeRequest: (() -> ())?
    var allChangeRequests: Results<ChangeRequestItem>?
    var changeReqArray: [changeRequest]?
    let realm = try? Realm()
    var enquiryId: Int = 0
    var changeRequestObj: ChangeRequest?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fetchChangeRequest?()
        changeRequestObj = ChangeRequest().searchChangeRequest(searchEqId: enquiryId)
        allChangeRequests = ChangeRequestItem().searchChangeRequestItems(searchId: changeRequestObj?.entityID ?? 0)
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
            row.cell.Label1.text = "Please Note:\nChange request is only one time facility to buyer for their ongoing order with you.\nDo consider with checking box if able to accept the request.".localized
            row.cell.Label2.text = "If you accept this change request, the buyer shall not be able to raise another change request".localized
        }
        <<< changeReqTypeView
        +++ changeReqTypeSection
        +++ Section()
        <<< ButtonRow() {
            $0.title = "SUBMIT".localized
        }.onCellSelection({ (cell, row) in
            self.changeReqArray?.removeAll()
            self.allChangeRequests?.forEach({ (changeReq) in
                if let row = self.form.rowBy(tag: changeReq.id) as? CRArtisanRow {
                    if row.cell.tickBtn.image(for: .normal) == UIImage.init(systemName: "checkmark.square.fill") {
                        let cr = changeRequest.init(changeRequestId: changeReq.changeRequestId, id: changeReq.entityID, requestItemsId: changeReq.requestItemsId, requestStatus: 1, requestText: changeReq.requestText)
                        self.changeReqArray?.append(cr)
                    }
                }
            })
            var showText = "You are about to reject the complete request".localized
            if self.changeReqArray?.count ?? 0 > 0 {
                showText = "You are about to partially accepted the change request".localized
                if self.changeReqArray?.count == self.allChangeRequests?.count {
                    showText = "You are about to accept the complete request".localized
                }
            }
            self.confirmAction("Are you sure?".localized, showText, confirmedCallback: { (action) in
                self.updateChangeRequest?(self.changeReqArray ?? [])
            }) { (action) in
                
            }
        })
        
        allChangeRequests?.forEach({ (changeReq) in
            changeReqTypeSection <<< CRArtisanRow() {
                $0.cell.height = { 50.0 }
                $0.cell.labelField.text = ChangeRequestType().searchChangeRequest(searchId: changeReq.requestItemsId)?.item ?? ""
                $0.cell.valuefield.text = changeReq.requestText ?? ""
                $0.cell.tickBtn.tag = changeReq.entityID
                $0.tag = changeReq.id
            }
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ChangeRequestUpdated"), object: nil, queue: .main) { (notif) in
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
            okBtn.addTarget(self, action: #selector(updateChangeRequestArtisan), for: .touchUpInside)
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
    
    @objc func updateChangeRequestArtisan() {
        if let initialView = self.view.viewWithTag(134) {
            self.view.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
            self.updateChangeRequest?(changeReqArray ?? [])
        }
    }
}
