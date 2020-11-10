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
    
    var updateChangeRequest: ((_ changeReqArr:[changeRequest], _ status: Int) -> ())?
    var fetchChangeRequest: (() -> ())?
    var allChangeRequests: Results<ChangeRequestItem>?
    var changeReqArray: [changeRequest]?
    let realm = try? Realm()
    var enquiryId: Int = 0
    var changeRequestObj: ChangeRequest?
    var status = 0
    
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
            row.cell.Label1.text = "Please Note:\nChange request is the only one-time facility to the buyer for their ongoing order with you.\nDo consider with checking the box if able to accept".localized
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
            self.status = 2
            if self.changeReqArray?.count ?? 0 > 0 {
                if self.changeReqArray?.count == self.allChangeRequests?.count {
                    showText = "You are about to accept the complete request".localized
                    self.status = 1
                }else {
                    showText = "You are about to partially accepted the change request".localized
                    self.status = 3
                }
            }
            let vc = UIAlertController(title: "Are you sure?".localized, message: showText, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {(act) in }))
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.updateChangeRequest?(self.changeReqArray ?? [], self.status)
            }))
            vc.addAction(UIAlertAction(title: "Go to this enquiry chat".localized, style: .default, handler: { (action) in
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    let service = ChatListService.init(client: client)
                    service.initiateConversation(vc: self, enquiryId: self.enquiryId)
                }catch {
                    print(error.localizedDescription)
                }
            }))
            self.present(vc, animated: true, completion: nil)
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
            Order().updateChangeStatus(status: self.status, enquiryId: self.enquiryId)
            self.hideLoading()
            self.confirmAction("Post the change request process".localized, "Update the pro forma invoice?\n\nyou have 2 days remaining to update your invoice after change request".localized, confirmedCallback: { (action) in
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.revisePI = true
                self.navigationController?.popViewController(animated: true)
            }) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
