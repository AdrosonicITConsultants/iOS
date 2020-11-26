//
//  OrderDetailController.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ViewRow
import WebKit

class OrderDetailController: FormViewController {
    var orderObject: AdminOrder?
    var getMOQ: GetMOQ?
    var getMOQs: GetMOQ?
    var listMOQs: [GetMOQs]?
    var listTransactions: [TransactionObject]?
    var viewWillAppear: (() -> ())?
    var checkMOQ: (() -> ())?
    var checkMOQs: (() -> ())?
    var checkTransactions: (() -> ())?
    var recreateOrder: (() -> ())?
    var orderDispatchAfterRecreation: (() -> ())?
    var getOrderProgress: (() -> ())?
    //    var orderProgress: OrderProgress?
    var isBuyerRatingDone: Int?
    var isArtisanRatingDone: Int?
    //    var allBuyerRatingResponse: Results<RatingResponseBuyer>?
    var isRatingFetched = 0
    var getPI: (() -> ())?
    var PI: GetPI?
    //    var advancePaymnet: PaymentStatus?
    //    var finalPaymnet: PaymentStatus?
    //    var finalPaymnetDetails: FinalPaymentDetails?
    lazy var viewModel = CreateMOQModel()
    var allDeliveryTimes: Results<EnquiryMOQDeliveryTimes>?
    //    var innerStages: Results<EnquiryInnerStages>?
    // var sendMOQ: (() -> ())?
    //  var acceptMOQ: (() -> ())?
    var sentMOQ: Int = 0
    var goToEnquiry: ((_ enquiryId: Int) -> ())?
    var downloadEnquiry: ((_ enquiryId: Int) -> ())?
    var viewPI: ((_ isOld: Int) -> ())?
    var downloadPI: ((_ isPI: Bool,_ isOld: Bool) -> ())?
    var downloadAdvReceipt: ((_ enquiryId: Int) -> ())?
    var downloadFinalReceipt: ((_ enquiryId: Int) -> ())?
    var downloadDeliveryReceipt: ((_ enquiryId: Int, _ imageName: String) -> ())?
    var viewTransactionReceipt: ((_ transactionObj: TransactionObject, _ isOld: Int, _ isPI: Bool) -> ())?
    var viewFI: (() -> ())?
    // var isMOQNeedToAccept: Int = 0
    var showCustomProduct: (() -> ())?
    var showProductDetails: (() -> ())?
    var showHistoryProductDetails: (() -> ())?
    var closeEnquiry: ((_ enquiryId: Int) -> ())?
    var toggleChangeRequest: ((_ enquiryId: Int, _ isEnabled: Int) -> ())?
    var fetchChangeRequest: (() -> ())?
    var raiseNewCRPI: (() -> ())?
    let realm = try? Realm()
    var isClosed = false
    var shouldCallToggle = true
    var containsOldPI = false
    var showChatDetails: (() -> ())?
    var allChangeRequests: Results<ChangeRequestItem>?
    var changeRequestObj: ChangeRequest?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        allDeliveryTimes = realm?.objects(EnquiryMOQDeliveryTimes.self).sorted(byKeyPath: "entityID")
        //        innerStages = realm?.objects(EnquiryInnerStages.self).sorted(byKeyPath: "entityID")
        //        allBuyerRatingResponse = realm!.objects(RatingResponseBuyer.self).filter("%K == %@", "enquiryId", orderObject?.enquiryId ?? 0).sorted(byKeyPath: "entityID")
        // checkMOQ?()
        // checkMOQs?()
        //        let client = try! SafeClient(wrapping: CraftExchangeClient())
        //        let service = EnquiryDetailsService.init(client: client)
        //        service.advancePaymentStatus(vc: self, enquiryId: self.orderObject?.entityID ?? 0)
        getPI?()
        checkTransactions?()
        getOrderProgress?()
        fetchChangeRequest?()
        //        service.finalPaymentStatus(vc: self, enquiryId: self.orderObject?.entityID ?? 0)
        //        service.finalPaymentDetails(vc: self, enquiryId: self.orderObject?.entityID ?? 0)
        
        let rightButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(goToChat))
        rightButtonItem.image = UIImage.init(named: "ios magenta chat")
        rightButtonItem.tintColor = UIColor().CEMagenda()
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        form
            +++ Section()
            <<< AdminEnquiryDetailRow() {
                $0.cell.height = { 545.0 }
                if let eqObj = orderObject {
                    $0.cell.configureCell(eqObj)
                }
            }
            /*
             <<< BuyerEnquirySectionViewRow() {
             $0.cell.height = { 40.0 }
             $0.tag = "View Rating"
             $0.cell.titleLbl.text = "Buyer rated you!".localized
             $0.cell.valueLbl.text = "View"
             $0.cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.7554848031, blue: 0.2052248061, alpha: 1)
             $0.cell.titleLbl.textColor = #colorLiteral(red: 0.5318118579, green: 0.3827857449, blue: 0, alpha: 1)
             $0.cell.valueLbl.textColor = #colorLiteral(red: 0.5318118579, green: 0.3827857449, blue: 0, alpha: 1)
             $0.cell.arrow.image = UIImage.init(systemName: "chevron.right")
             $0.cell.arrow.tintColor = #colorLiteral(red: 0.5318118579, green: 0.3827857449, blue: 0, alpha: 1)
             $0.hidden = true
             if self.orderObject?.enquiryStageId != nil && self.isBuyerRatingDone != nil{
             if (User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 10 && self.isBuyerRatingDone! == 1) {
             $0.hidden = false
             }
             }
             
             }.onCellSelection({ (cell, row) in
             if self.orderObject != nil {
             do {
             let client = try SafeClient(wrapping: CraftExchangeClient())
             let vc = ViewRatingController.init(style: .plain)
             vc.orderObject = self.orderObject
             self.navigationController?.pushViewController(vc, animated: false)
             }catch {
             print(error.localizedDescription)
             }
             }
             }).cellUpdate({ (cell, row) in
             
             if self.orderObject?.enquiryStageId != nil && self.isBuyerRatingDone != nil{
             if (User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 10 && self.isBuyerRatingDone! == 1) {
             cell.row.hidden = false
             }
             cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
             var ResponseArray:[Int] = []
             if self.allBuyerRatingResponse != nil{
             for object in self.allBuyerRatingResponse! {
             if object.responseComment == nil {
             ResponseArray.append(object.response)
             cell.valueLbl.text = "\((Double(ResponseArray.reduce(0, +))/Double(ResponseArray.count)))"
             }
             }
             }
             
             }
             })*/
            
            <<< LabelRow(){
                $0.title = "Order Details".localized
                $0.cell.contentView.backgroundColor = .black
            }
            /*
             <<< SwitchRow() {
             $0.title = "Change Request".localized
             $0.tag = "CRRow"
             if orderObject?.productStatus == 2 {
             $0.hidden = true
             }else {
             $0.hidden = false
             }
             $0.value = orderObject?.changeRequestOn == 1 ? true : false
             }.onChange({ (row) in
             if self.shouldCallToggle {
             print("CR Disabled")
             self.toggleChangeRequest?(self.orderObject?.enquiryId ?? 0, 0)
             }else {
             self.shouldCallToggle = true
             }
             }).cellUpdate({ (cell, row) in
             if self.orderObject?.enquiryStageId ?? 0 < 6 && self.isClosed == false && User.loggedIn()?.refRoleId == "1" && self.orderObject?.changeRequestOn == 1 {
             if self.orderObject?.changeRequestStatus == nil || self.orderObject?.changeRequestStatus == 0 {
             cell.isUserInteractionEnabled = true
             }else {
             cell.isUserInteractionEnabled = false
             }
             }else {
             cell.isUserInteractionEnabled = false
             }
             })*/
            /*
             <<< LabelRow(){
             $0.tag = "Order under Recreation"
             // $0.cell.height = { 60.0 }
             $0.hidden = true
             $0.title = "Order under Recreation".localized
             if self.orderObject?.isReprocess == 1  {
             $0.hidden = false
             }
             if User.loggedIn()?.refRoleId == "2" {
             $0.title = """
             Order under Recreation
             Kindly refer chats for regular updates and in-case of any inconvenience, feel free to escalate the issue over chat
             """.localized
             }
             if User.loggedIn()?.refRoleId == "1" {
             $0.title = """
             Order under Recreation
             Kindly keep updating buyer about the status of product over chat
             """
             }
             
             $0.cellStyle = .default
             $0.cell.textLabel?.numberOfLines = 5
             }.cellUpdate({ (cell, row) in
             cell.textLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
             cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
             cell.textLabel?.textAlignment = .center
             // row.hidden = true
             if self.orderObject?.isReprocess == 1 {
             row.hidden = false
             }
             if User.loggedIn()?.refRoleId == "2" {
             cell.row.title = """
             Order under Recreation
             Kindly refer chats for regular updates and in-case of any inconvenience, feel free to escalate the issue over chat
             """
             }
             if User.loggedIn()?.refRoleId == "1" {
             cell.row.title = """
             Order under Recreation
             Kindly keep updating buyer about the status of product over chat
             """.localized
             }
             })*/
            /*
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Recreate Order"
             $0.cell.tag = 107
             $0.cell.nextStepsLabel.text = "Want to recreate order?".localized
             $0.cell.createSendInvoiceBtn.setTitle("Order recreation".localized, for: .normal)
             $0.cell.createSendInvoiceBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
             $0.cell.createSendInvoiceBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
             // $0.cell.createSendInvoiceBtn.layer.cornerRadius = 15
             $0.cell.createSendInvoiceBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
             $0.hidden = true
             if orderObject != nil {
             if self.orderObject!.isReprocess == 0 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderProgress?.artisanReviewId == "2" {
             $0.hidden = false
             }
             }
             
             }.cellUpdate({ (cell, row) in
             if self.orderObject != nil {
             if self.orderObject!.isReprocess == 0 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderProgress?.artisanReviewId == "2" {
             cell.row.hidden = false
             }else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             }
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Close Order"
             $0.cell.tag = 105
             $0.cell.nextStepsLabel.text = "Want to close order?"
             $0.cell.createSendInvoiceBtn.setTitle("Close Order", for: .normal)
             $0.cell.createSendInvoiceBtn.backgroundColor = #colorLiteral(red: 0.918557363, green: 0, blue: 0, alpha: 1)
             $0.cell.createSendInvoiceBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
             $0.hidden = true
             if orderObject != nil {
             if self.orderObject!.enquiryStageId <= 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed && self.orderObject?.isPartialRefundReceived == 1 {
             $0.hidden = false
             }
             }
             }.cellUpdate({ (cell, row) in
             if self.orderObject != nil {
             if self.orderObject!.enquiryStageId <= 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed && self.orderObject?.isPartialRefundReceived == 1 {
             cell.row.hidden = false
             }else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             }
             })
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Is Partial Refund Received?"
             $0.cell.tag = 106
             $0.cell.nextStepsLabel.text = "Is Partial Refund Received?"
             $0.cell.createSendInvoiceBtn.setTitle("Is Partial Refund Received?", for: .normal)
             $0.cell.createSendInvoiceBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5, blue: 0, alpha: 1)
             $0.hidden = true
             if orderObject != nil {
             if self.orderObject!.enquiryStageId <= 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed && self.orderObject?.isPartialRefundReceived == 0 {
             $0.hidden = false
             }
             }
             }.cellUpdate({ (cell, row) in
             if self.orderObject != nil {
             if self.orderObject!.enquiryStageId <= 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed && self.orderObject?.isPartialRefundReceived == 0 {
             cell.row.hidden = false
             }else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             }
             })
             
             
             <<< StatusRow() {
             $0.cell.height = { 110.0 }
             }.cellUpdate({ (cell, row) in
             cell.previousStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (self.orderObject?.enquiryStageId ?? 0) - 1)?.stageDescription ?? "NA")"
             if self.orderObject!.enquiryStageId == 3 && self.orderObject?.productStatusId == 2 {
             cell.previousStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (self.orderObject?.enquiryStageId ?? 0) - 4)?.stageDescription ?? "NA")"
             }
             if self.orderObject?.enquiryStageId == 5 && self.orderObject!.innerEnquiryStageId >= 2{
             cell.previousStatusLbl.text = "\(EnquiryInnerStages.getStageType(searchId: (self.orderObject?.innerEnquiryStageId ?? 0) - 1)?.stageDescription ?? "NA")"
             }
             
             cell.currentStatusLbl.text = "\(EnquiryStages.getStageType(searchId: self.orderObject?.enquiryStageId ?? 0)?.stageDescription ?? "NA")"
             if self.orderObject?.enquiryStageId == 5{
             cell.currentStatusLbl.text = "\(EnquiryInnerStages.getStageType(searchId: self.orderObject?.innerEnquiryStageId ?? 0)?.stageDescription ?? "NA")"
             
             }
             cell.nextStatusLbl.text = "\(EnquiryStages.getStageType(searchId: (self.orderObject?.enquiryStageId ?? 0) + 1)?.stageDescription ?? "NA")"
             if self.orderObject!.enquiryStageId == 3 && self.orderObject?.productStatusId == 2 {
             cell.nextStatusLbl.text = "\(AvailableProductStages.getStageType(searchId: (self.orderObject?.enquiryStageId ?? 0) + 4)?.stageDescription ?? "NA")"
             }
             
             if self.orderObject?.enquiryStageId == 5 && self.orderObject!.innerEnquiryStageId <= 4{
             cell.nextStatusLbl.text = "\(EnquiryInnerStages.getStageType(searchId: (self.orderObject?.innerEnquiryStageId ?? 0) + 1)?.stageDescription ?? "NA")"
             
             }
             if self.orderObject?.enquiryStageId == 10 {
             cell.nextStatusLbl.text = "Completed"
             }
             if (self.orderObject?.isBlue ?? false == true) && (self.orderObject?.enquiryStageId == 3){
             cell.actionLbl.text = "Advance payment Awaiting"
             }else if (self.orderObject?.isBlue ?? false == true) && (self.orderObject?.enquiryStageId == 8){
             cell.actionLbl.text = "Final payment Awaiting"
             }
             else {
             cell.actionLbl.text = ""
             }
             if self.isClosed {
             row.hidden = true
             }
             })*/
            
            <<< EnquiryClosedRow() {
                $0.cell.height = { 110.0 }
                if orderObject?.currenStageId == 10 {
                    $0.cell.dotView.backgroundColor = UIColor().CEGreen()
                    $0.cell.enquiryLabel.text = "Order Completed".localized
                    $0.cell.enquiryLabel.textColor = UIColor().CEGreen()
                }else {
                    $0.cell.dotView.backgroundColor = .red
                    $0.cell.enquiryLabel.text = "Order Closed".localized
                    $0.cell.enquiryLabel.textColor = .red
                }
                $0.hidden = isClosed == true ? false : true
            }
            /*
             <<< ProvideRatingButtonRow() {
             $0.cell.height = { 125.0 }
             $0.tag = "Provide Rating"
             $0.cell.tag = 101
             $0.cell.delegate = self
             $0.hidden = true
             if orderObject != nil {
             if self.orderObject!.enquiryStageId >= 10 && self.isClosed {
             $0.hidden = false
             }
             }
             }.cellUpdate({ (cell, row) in
             if self.orderObject != nil {
             if self.orderObject!.enquiryStageId >= 10 && self.isClosed {
             cell.row.hidden = false
             }
             }
             })
             
             <<< ConfirmDeliveryRow() {
             $0.cell.height = { 175.0 }
             $0.tag = "Confirm Delivery & Complete Order"
             $0.cell.tag = 100
             $0.cell.delegate = self
             $0.hidden = true
             if self.orderObject?.enquiryStageId == 10 && User.loggedIn()?.refRoleId == "2" && !self.isClosed {
             $0.hidden = false
             }
             }.cellUpdate({ (cell, row) in
             
             if self.orderObject?.enquiryStageId == 10 && User.loggedIn()?.refRoleId == "2" && !self.isClosed {
             cell.row.hidden = false
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< LabelRow(){
             $0.cell.height = {30.0}
             $0.title = ""
             }.cellUpdate({ (cell, row) in
             cell.selectionStyle = .none
             })
             
             <<< StartStageViewRow()
             {
             $0.cell.height = { 90.0 }
             $0.cell.tag = 6
             $0.tag = "Start Production Stage"
             $0.cell.delegate = self
             if User.loggedIn()?.refRoleId == "1" && orderObject?.enquiryStageId == 4 && isClosed == false {
             $0.hidden = false
             }
             else{
             $0.hidden = true
             }
             }.cellUpdate({ (cell, row) in
             if User.loggedIn()?.refRoleId == "1" && self.orderObject?.enquiryStageId == 4 && self.isClosed == false {
             cell.row.hidden = false
             cell.height = { 90.0 }
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< MarkCompleteAndNextRow()
             {
             $0.cell.height = { 125.0 }
             $0.cell.tag = 7
             $0.tag = "Production Stages Progrees"
             $0.cell.MarkProgress.layer.borderColor = UIColor(red: 83.0/255.0, green: 186.0/255.0, blue: 183.0/255.0, alpha: 1.0).cgColor
             $0.cell.MarkProgress.layer.borderWidth = 2.0
             $0.cell.delegate = self
             if User.loggedIn()?.refRoleId == "1" && self.orderObject?.enquiryStageId == 5 && isClosed == false {
             $0.hidden = false
             }
             else{
             $0.hidden = true
             }
             }.cellUpdate({ (cell, row) in
             if User.loggedIn()?.refRoleId == "1" && self.orderObject?.enquiryStageId == 5 && self.isClosed == false {
             cell.row.hidden = false
             cell.height = { 125.0 }
             }
             else {
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Create Final Invoice"
             $0.cell.tag = 100
             $0.cell.nextStepsLabel.text = "Next Step -------------------->  Create & Send Final Invoice".localized
             $0.cell.createSendInvoiceBtn.setTitle("Create & Send Final Invoice".localized, for: .normal)
             if User.loggedIn()?.refRoleId == "1" && (orderObject?.enquiryStageId ?? 0 <= 7 ) && !self.isClosed{
             $0.hidden = false
             }
             else{
             $0.hidden = true
             $0.cell.height = { 0.0 }
             }
             }
             .cellUpdate({ (cell, row) in
             if User.loggedIn()?.refRoleId == "1" && ( self.orderObject?.enquiryStageId ?? 0 <= 7) && !self.isClosed {
             cell.row.hidden = false
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Upload delivery receipt"
             $0.cell.tag = 101
             $0.cell.nextStepsLabel.text = "Next Step -------------------->  Upload delivery receipt".localized
             $0.cell.createSendInvoiceBtn.setTitle("Upload delivery receipt".localized, for: .normal)
             $0.hidden = true
             if orderObject?.enquiryStageId != nil {
             if self.orderObject!.enquiryStageId >= 9 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderObject?.deliveryChallanUploaded != 1 {
             $0.hidden = false
             }
             
             }
             
             }
             .cellUpdate({ (cell, row) in
             if self.orderObject?.enquiryStageId != nil {
             if (self.orderObject?.enquiryStageId)! >= 9 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderObject?.deliveryChallanUploaded != 1 {
             cell.row.hidden = false
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             }
             
             
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Upload final payment receipt"
             $0.cell.tag = 102
             $0.cell.nextStepsLabel.text = "Next Step -------------------->  Upload final payment receipt".localized
             $0.cell.createSendInvoiceBtn.setTitle("Upload final payment receipt".localized, for: .normal)
             if self.orderObject?.enquiryStageId == 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed {
             $0.hidden = false
             }
             else {
             $0.hidden = true
             }
             }
             .cellUpdate({ (cell, row) in
             
             if self.orderObject?.enquiryStageId == 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed {
             cell.row.hidden = false
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Approve final payment receipt"
             $0.cell.tag = 103
             $0.cell.nextStepsLabel.text = "Next Step -------------------->  Approve final payment".localized
             $0.cell.createSendInvoiceBtn.setTitle("Approve final payment".localized, for: .normal)
             if self.orderObject?.enquiryStageId == 8 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderObject?.isBlue ?? false{
             // orderObject?.isBlue
             $0.hidden = false
             }
             else {
             $0.hidden = true
             }
             }.cellUpdate({ (cell, row) in
             
             if self.orderObject?.enquiryStageId == 8 && User.loggedIn()?.refRoleId == "1" && !self.isClosed  && self.orderObject?.isBlue ?? false{
             cell.row.hidden = false
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Order Dispacthed"
             $0.cell.tag = 104
             $0.cell.nextStepsLabel.text = "Next Step -------------------->  Mark Order as Dispatched".localized
             $0.cell.createSendInvoiceBtn.setTitle("Mark Order as Dispatched".localized, for: .normal)
             $0.cell.createSendInvoiceBtn.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
             $0.hidden = true
             if self.orderObject?.enquiryStageId == 9 && User.loggedIn()?.refRoleId == "1" && !self.isClosed {
             $0.hidden = false
             }
             
             }.cellUpdate({ (cell, row) in
             
             if self.orderObject?.enquiryStageId == 9 && User.loggedIn()?.refRoleId == "1" && !self.isClosed {
             cell.row.hidden = false
             }
             else{
             cell.row.hidden = true
             cell.height = { 0.0 }
             }
             })
             
             <<< ProFormaInvoiceRow() {
             $0.cell.height = { 85.0 }
             $0.cell.delegate = self
             $0.tag = "Mark order dispatched after recreation"
             $0.cell.tag = 108
             $0.cell.nextStepsLabel.text = "Next Steps ----------------------------->   Mark order dispatched after recreation".localized
             $0.cell.createSendInvoiceBtn.setTitle("Mark order dispatched after recreation".localized, for: .normal)
             $0.cell.createSendInvoiceBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
             $0.cell.createSendInvoiceBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
             $0.cell.createSendInvoiceBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
             $0.hidden = true
             if orderObject?.isReprocess == 1 && User.loggedIn()?.refRoleId == "1"  {
             $0.hidden = false
             }
             
             }.cellUpdate({ (cell, row) in
             if self.orderObject?.isReprocess == 1 && User.loggedIn()?.refRoleId == "1"  {
             cell.row.hidden = false
             }
             })*/
            /*
             <<< BuyerEnquirySectionViewRow() {
             $0.cell.height = { 44.0 }
             $0.tag = "Raise Concern"
             $0.cell.titleLbl.text = "Eh! Problem?".localized
             $0.cell.valueLbl.text = "Raise a concern"
             if User.loggedIn()?.refRoleId == "1"{
             $0.cell.titleLbl.text = "Concern Raised".localized
             $0.cell.valueLbl.text = "View".localized
             }
             $0.cell.contentView.backgroundColor = UIColor().EQBrownBg()
             $0.cell.titleLbl.textColor = UIColor().EQBrownText()
             $0.cell.valueLbl.textColor = UIColor().EQBrownText()
             $0.hidden = true
             if self.orderObject?.enquiryStageId != nil {
             if (orderProgress?.isFaulty == 1 && !self.isClosed && User.loggedIn()?.refRoleId == "1") || ( User.loggedIn()?.refRoleId == "2" && self.orderObject!.enquiryStageId >= 10 && !self.isClosed && self.orderProgress?.artisanReviewId != "2" && self.orderObject?.isReprocess != 1) {
             $0.hidden = false
             }
             
             }
             }.onCellSelection({ (cell, row) in
             if self.orderObject != nil && self.orderProgress != nil{
             do {
             let client = try SafeClient(wrapping: CraftExchangeClient())
             
             let vc = OrderDetailsService(client: client).createRaiseConcernScene(forOrder: self.orderObject, enquiryId: self.orderObject!.enquiryId) as! RaiseConcernController
             
             vc.orderObject = self.orderObject
             self.navigationController?.pushViewController(vc, animated: false)
             }catch {
             print(error.localizedDescription)
             }
             }
             }).cellUpdate({ (cell, row) in
             if User.loggedIn()?.refRoleId == "1"{
             cell.titleLbl.text = "Concern Raised".localized
             cell.valueLbl.text = "View".localized
             }
             if self.orderObject?.enquiryStageId != nil {
             if (self.orderProgress?.isFaulty == 1 && !self.isClosed && User.loggedIn()?.refRoleId == "1") || ( User.loggedIn()?.refRoleId == "2" && self.orderObject!.enquiryStageId >= 10 && !self.isClosed && self.orderProgress?.artisanReviewId != "2" && self.orderObject?.isReprocess != 1){
             cell.row.hidden = false
             }
             }
             })
             
             <<< BuyerEnquirySectionViewRow() {
             $0.cell.height = { 44.0 }
             $0.tag = "Delivery Receipt"
             $0.cell.titleLbl.text = "Delivery Receipt".localized
             $0.cell.valueLbl.text = "View".localized
             $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
             $0.cell.titleLbl.textColor = UIColor().EQBlueText()
             $0.cell.valueLbl.textColor = UIColor().EQBlueText()
             $0.hidden = true
             if self.orderObject?.enquiryStageId != nil {
             if User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 9 && self.orderObject?.deliveryChallanUploaded == 1 {
             $0.hidden = false
             }
             if User.loggedIn()?.refRoleId == "2" && self.orderObject!.enquiryStageId >= 10 && self.orderObject?.deliveryChallanUploaded == 1 {
             $0.hidden = false
             }
             }
             }.onCellSelection({ (cell, row) in
             if self.orderObject != nil {
             self.showLoading()
             self.downloadDeliveryReceipt?(self.orderObject?.enquiryId ?? 0, self.orderObject?.deliveryChallanLabel ?? "")
             }
             }).cellUpdate({ (cell, row) in
             
             if self.orderObject?.enquiryStageId != nil {
             if User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 9 && self.orderObject?.deliveryChallanUploaded == 1 {
             cell.row.hidden = false
             }
             if User.loggedIn()?.refRoleId == "2" && self.orderObject!.enquiryStageId >= 10 && self.orderObject?.deliveryChallanUploaded == 1 {
             cell.row.hidden = false
             }
             }
             })*/
            <<< MOQSectionTitleRow() {
                $0.cell.height = { 44.0 }
                $0.tag = "Check MOQ Buyer"
                $0.cell.titleLbl.text = "Check MOQ"
                $0.cell.noOfUnitLbl.text = "70 pcs"
                $0.cell.costLbl.text = "Rs 1000"
                $0.cell.etaLbl.text = "100 days"
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.noOfUnitLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.costLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.etaLbl.textColor = UIColor.init(named: "AdminGreenText")
            }.onCellSelection({ (cell, row) in
                let row1 = self.form.rowBy(tag: "MOQ1")
                let row2 = self.form.rowBy(tag: "MOQ2")
                let row3 = self.form.rowBy(tag: "MOQ3")
                if row1?.isHidden == true {
                    row1?.hidden = false
                    row2?.hidden = false
                    row3?.hidden = false
                }else {
                    row1?.hidden = true
                    row2?.hidden = true
                    row3?.hidden = true
                }
                row1?.evaluateHidden()
                row2?.evaluateHidden()
                row3?.evaluateHidden()
                self.form.allSections.first?.reload(with: .none)
            }).cellUpdate({ (cell, row) in
                if self.getMOQs != nil{
                    cell.noOfUnitLbl.text = "\(self.getMOQs!.moq) pcs"
                    cell.costLbl.text = "Rs " + self.getMOQs!.ppu!
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: self.getMOQs!.deliveryTimeId)!.days
                    cell.etaLbl.text = "\(ETAdays) days"
                }
                
            })
            
            <<< MOQValueRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "MOQ1"
                $0.cell.unitLbl.text = "MOQ"
                $0.cell.valueLbl.text = "70 pcs"
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.backgroundColor = .black
                if self.getMOQs != nil{
                    cell.valueLbl.text = "\(self.getMOQs!.moq) pcs"
                }
            })
            
            <<< MOQValueRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "MOQ2"
                $0.cell.unitLbl.text = "Price/unit(or m)"
                $0.cell.valueLbl.text = "Rs 1000"
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.backgroundColor = .black
                if self.getMOQs != nil{
                    cell.valueLbl.text = "Rs " + self.getMOQs!.ppu!
                }
            })
            
            <<< MOQValueRow() {
                $0.cell.height = { 60.0 }
                $0.tag = "MOQ3"
                $0.cell.unitLbl.text = "ETA Delivery"
                $0.cell.valueLbl.text = "100 days"
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.backgroundColor = .black
                if self.getMOQs != nil{
                    let ETAdays = EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: self.getMOQs!.deliveryTimeId)!.days
                    cell.valueLbl.text = "\(ETAdays) days"
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check PI".localized
                $0.cell.valueLbl.text = "View".localized
                $0.cell.contentView.backgroundColor = UIColor.init(named: "ArmyGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "ArmyGreenText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "ArmyGreenText")
                if self.orderObject?.currenStageId ?? 0 >= 3 {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }.onCellSelection({ (cell, row) in
                self.showLoading()
                self.viewPI?(0)
            }).cellUpdate({ (cell, row) in
                if self.orderObject?.currenStageId ?? 0 >= 3 {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Check Product Details"
                $0.cell.valueLbl.text = "\(orderObject?.tag ?? "View")"
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminBlueBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminBlueText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminBlueText")
            }.onCellSelection({ (cell, row) in
                if self.orderObject?.customProductId != 0 {
                    // self.showCustomProduct?()
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeClient())
                        let vc = ProductCatalogService(client: client).createAdminProductDetailScene(forProductId: self.orderObject?.customProductId, isCustom: true, isRedirect: false, enquiryCode: self.orderObject?.code, buyerBrand: self.orderObject?.buyerBrand, enquiryDate: Date().ttceISOString(isoDate: self.orderObject?.dateStarted ?? Date()) , enquiryId: self.orderObject?.entityID ?? 0)
                        
                        vc.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(vc, animated: true)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
                    //                else if self.enquiryObject?.productHistoryId != 0 {
                    //                    self.showHistoryProductDetails?()
                    //                }
                else {
                    self.showProductDetails?()
                }
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Tax Invoice".localized
                $0.cell.valueLbl.text = "View".localized
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminPurpleBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminPurpleText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminPurpleText")
            }.onCellSelection({ (cell, row) in
                if self.orderObject?.currenStageId != nil {
                    if self.orderObject!.currenStageId >= 8 {
                        self.viewFI?()
                        print("show tax invoice")
                    }else{
                        self.alert("Tax Invoice not yet created".localized)
                    }
                }
                
            })
            
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Quality Check".localized
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminGreenText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminGreenText")
            }.onCellSelection({ (cell, row) in
                do {
                    let client = try SafeClient(wrapping: CraftExchangeClient())
                    if let order = self.orderObject {
                        let vc = QCService(client: client).createQCBuyerScene(forOrder: order)
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                    
                }catch {
                    print(error.localizedDescription)
                }
            })
            /*
             <<< BuyerEnquirySectionViewRow() {
             $0.cell.height = { 44.0 }
             $0.cell.titleLbl.text = "Change Request".localized
             $0.cell.contentView.backgroundColor = UIColor().EQPurpleBg()
             $0.cell.titleLbl.textColor = UIColor().EQPurpleText()
             $0.cell.valueLbl.textColor = UIColor().EQPurpleText()
             }.cellUpdate({ (cell, row) in
             switch(self.orderObject?.changeRequestStatus) {
             case 0:
             if self.orderObject?.productStatusId == 2 {
             row.cell.valueLbl.text = "Change request is not applicable for in stock products".localized
             }else {
             if self.orderObject?.enquiryStageId ?? 0 < 6 {
             if self.orderObject?.changeRequestModifiedOn != nil {
             if User.loggedIn()?.refRoleId == "1" {
             row.cell.valueLbl.text = "Buyer Waiting for Acknowledgement".localized
             }else {
             row.cell.valueLbl.text = "Awaiting for Acknowledgement".localized
             }
             }else {
             if self.orderObject?.changeRequestOn == 0 {
             row.cell.valueLbl.text = User.loggedIn()?.refRoleId == "1" ? "Change request disabled".localized : "Change request disabled by artisan".localized
             }else {
             if (self.orderObject?.changeRequestModifiedOn == nil && User.loggedIn()?.refRoleId == "1") ||
             (User.loggedIn()?.refRoleId == "2" &&
             ( Date() < (Calendar.current.date(byAdding: .day, value: 10, to: self.orderObject?.orderCreatedOn ?? Date()) ?? Date()))
             ){
             row.cell.valueLbl.text = "No change request available"
             }else{
             row.cell.valueLbl.text = "Last date to raise Change Request passed.".localized
             }
             
             
             }
             
             }
             }else {
             row.cell.valueLbl.text = "Last date to raise Change Request passed.".localized
             }
             }
             case 1:
             row.cell.valueLbl.text = "Change request has been accepted".localized
             case 2:
             row.cell.valueLbl.text = "Change request has been rejected".localized
             case 3:
             row.cell.valueLbl.text = "Change request has been partially accepted".localized
             case .none, .some(_):
             row.cell.valueLbl.text = "No change request raised".localized
             }
             }).onCellSelection({ (cell, row) in
             
             if self.orderObject?.enquiryStageId ?? 0 < 6 {
             if self.orderObject?.productStatusId != 2 && self.orderObject?.changeRequestOn == 1 {
             var execute = false
             
             if (self.orderObject?.changeRequestModifiedOn != nil && User.loggedIn()?.refRoleId == "1") ||
             (User.loggedIn()?.refRoleId == "2" &&
             ( Date() < (Calendar.current.date(byAdding: .day, value: 10, to: self.orderObject?.orderCreatedOn ?? Date()) ?? Date()))
             ){
             execute = true
             }
             if execute {
             do {
             //                            let client = try SafeClient(wrapping: CraftExchangeClient())
             //                            if User.loggedIn()?.refRoleId == "2" && self.orderObject?.changeRequestModifiedOn == nil {
             //                                let vc = OrderDetailsService(client: client).createBuyerChangeRequestScene(forEnquiry: self.orderObject?.enquiryId ?? 0)
             //                                self.navigationController?.pushViewController(vc, animated: false)
             //                            }else if User.loggedIn()?.refRoleId == "1" && self.orderObject?.changeRequestStatus == 0 {
             self.fetchChangeRequest?()
             //                            }
             }catch {
             print(error.localizedDescription)
             }
             }
             }
             }
             })*/
            +++ Section()
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Change Request".localized
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor.init(named: "AdminBlueBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "AdminBlueText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "AdminBlueText")
            }.onCellSelection({ (cell, row) in
                let section = self.form.sectionBy(tag: "list CR")
                if section?.isEmpty == true {
                    self.listCRs()
                }else {
                    section?.removeAll()
                }
                section?.reload()
                
            })
            +++ Section(){ section in
                section.tag = "list CR"
            }
            +++ Section()
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                $0.cell.titleLbl.text = "Your Transactions".localized
                $0.cell.valueLbl.text = ""
                $0.cell.contentView.backgroundColor = UIColor.init(named: "ArmyGreenBG")
                $0.cell.titleLbl.textColor = UIColor.init(named: "ArmyGreenText")
                $0.cell.valueLbl.textColor = UIColor.init(named: "ArmyGreenText")
            }.onCellSelection({ (cell, row) in
                let section = self.form.sectionBy(tag: "list Transactions")
                if section?.isEmpty == true {
                    self.listTransactionsFunc()
                }else {
                    section?.removeAll()
                }
                section?.reload()
                
            })
            +++ Section(){ section in
                section.tag = "list Transactions"
        }
        
        
        
        if tableView.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
        }
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
        /*let appDelegate = UIApplication.shared.delegate as? AppDelegate
         if appDelegate?.revisePI ?? false {
         appDelegate?.revisePI = false
         self.showLoading()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
         self.hideLoading()
         self.viewProformaInvoiceBtnSelected(tag: self.orderObject?.entityID ?? 0)
         }
         }*/
    }
    
    @objc func pullToRefresh() {
        viewWillAppear?()
    }
    
    @objc func goToChat() {
        
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ChatDetailsService(client: client).createScene(enquiryId: orderObject?.entityID ?? 0)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            
        }catch {
            print(error.localizedDescription)
        }
        
    }
    
    func reloadFormData() {
        orderObject = realm?.objects(AdminOrder.self).filter("%K == %@","entityID",orderObject?.entityID ?? 0).first
        /*
         if self.orderObject?.enquiryStageId != nil && self.isBuyerRatingDone != nil{
         if (User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 10 && self.isBuyerRatingDone! == 1) {
         let row = form.rowBy(tag: "View Rating")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         }
         
         if self.orderObject?.isReprocess == 1  {
         let row = form.rowBy(tag: "Order under Recreation")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }else{
         let row = form.rowBy(tag: "Order under Recreation")
         row?.hidden = true
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         
         if orderObject?.isReprocess == 1 && User.loggedIn()?.refRoleId == "1"  {
         let row = form.rowBy(tag: "Mark order dispatched after recreation".localized)
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }else{
         let row = form.rowBy(tag: "Mark order dispatched after recreation".localized)
         row?.hidden = true
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         
         if orderObject != nil {
         if self.orderObject!.isReprocess == 0 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderProgress?.artisanReviewId == "2" {
         let row = form.rowBy(tag: "Recreate Order")
         row?.hidden = false
         row?.evaluateHidden()
         }
         self.form.allSections.first?.reload(with: .none)
         }
         
         
         if self.orderObject?.enquiryStageId != nil {
         if (orderProgress?.isFaulty == 1 && !self.isClosed && User.loggedIn()?.refRoleId == "1") || ( User.loggedIn()?.refRoleId == "2" && self.orderObject!.enquiryStageId >= 10 && !self.isClosed && self.orderProgress?.artisanReviewId != "2" && self.orderObject?.isReprocess != 1){
         let row = form.rowBy(tag: "Raise Concern")
         row?.hidden = false
         row?.evaluateHidden()
         }else{
         let row = form.rowBy(tag: "Raise Concern")
         row?.hidden = true
         row?.evaluateHidden()
         }
         self.form.allSections.first?.reload(with: .none)
         
         
         }
         if orderObject != nil {
         let row = form.rowBy(tag: "Want to close order?")
         if self.orderObject!.enquiryStageId <= 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed && self.orderObject?.isPartialRefundReceived == 1 {
         row?.hidden = false
         row?.evaluateHidden()
         }else{
         row?.hidden = true
         row?.evaluateHidden()
         }
         self.form.allSections.first?.reload(with: .none)
         }
         if orderObject != nil {
         let row = form.rowBy(tag: "Is Partial Refund Received?")
         if self.orderObject!.enquiryStageId <= 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed && self.orderObject?.isPartialRefundReceived == 0 {
         row?.hidden = false
         row?.evaluateHidden()
         }else{
         row?.hidden = true
         row?.evaluateHidden()
         }
         self.form.allSections.first?.reload(with: .none)
         }
         if User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 4  {
         let row = form.rowBy(tag: "Check advance Payment receipt")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         //"Create Final Invoice"
         if User.loggedIn()?.refRoleId == "1" && (orderObject?.enquiryStageId ?? 0 <= 7) && !self.isClosed{
         let row = form.rowBy(tag: "Create Final Invoice")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         //        else if User.loggedIn()?.refRoleId == "1" && self.orderObject?.productStatusId == 2 && orderObject?.enquiryStageId == 3 {
         //            let row = form.rowBy(tag: "Create Final Invoice")
         //            row?.hidden = false
         //            row?.evaluateHidden()
         //            self.form.allSections.first?.reload(with: .none)
         //        }
         else{
         let row = form.rowBy(tag: "Create Final Invoice")
         row?.hidden = true
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         
         if self.orderObject?.enquiryStageId == 8 && User.loggedIn()?.refRoleId == "2" && !self.isClosed {
         let row = form.rowBy(tag: "Upload final payment receipt")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         else {
         let row = form.rowBy(tag: "Upload final payment receipt")
         row?.hidden = true
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         
         if self.orderObject?.enquiryStageId == 8 && User.loggedIn()?.refRoleId == "1" && !self.isClosed  && self.orderObject?.isBlue ?? false{
         let row = form.rowBy(tag: "Approve final payment receipt")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         else {
         let row = form.rowBy(tag: "Approve final payment receipt")
         row?.hidden = true
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         
         if User.loggedIn()?.refRoleId == "1" && self.orderObject!.enquiryStageId >= 9 && self.orderObject?.deliveryChallanUploaded == 1 {
         let row = form.rowBy(tag: "Delivery Receipt")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         if User.loggedIn()?.refRoleId == "2" && self.orderObject!.enquiryStageId >= 10 && self.orderObject?.deliveryChallanUploaded == 1 {
         let row = form.rowBy(tag: "Delivery Receipt")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         if self.orderObject?.enquiryStageId == 9 && User.loggedIn()?.refRoleId == "1" && !self.isClosed {
         let row = form.rowBy(tag: "Order Dispacthed")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         if self.orderObject?.enquiryStageId == 10 && User.loggedIn()?.refRoleId == "2" && !self.isClosed {
         let row = form.rowBy(tag: "Confirm Delivery & Complete Order")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         if self.orderObject?.enquiryStageId != nil {
         if self.orderObject!.enquiryStageId >= 9 && User.loggedIn()?.refRoleId == "1" && !self.isClosed && self.orderObject?.deliveryChallanUploaded != 1 {
         let row = form.rowBy(tag: "Upload delivery receipt")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }else{
         let row = form.rowBy(tag: "Upload delivery receipt")
         row?.hidden = true
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         }
         
         //        if self.orderObject!.enquiryStageId == 3 && User.loggedIn()?.refRoleId == "1"{
         //            let row = form.rowBy(tag: "View Invoice & Approve Advance Payment")
         //            row?.hidden = false
         //            row?.evaluateHidden()
         //            self.form.allSections.first?.reload(with: .none)
         //        }
         if User.loggedIn()?.refRoleId == "1" && self.orderObject?.enquiryStageId == 4{
         let row = form.rowBy(tag: "Start Production Stage")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         if User.loggedIn()?.refRoleId == "1" && self.orderObject?.enquiryStageId == 5 {
         let row = form.rowBy(tag: "Production Stages Progrees")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         if self.orderObject?.enquiryStageId == 2 && User.loggedIn()?.refRoleId == "1"{
         let row = form.rowBy(tag: "CreatePI")
         row?.hidden = false
         row?.evaluateHidden()
         self.form.allSections.first?.reload(with: .none)
         }
         //        if (self.orderObject?.enquiryStageId == 2 && User.loggedIn()?.refRoleId == "2"){
         //            let row = form.rowBy(tag: "Check MOQ Buyer")
         //            row?.hidden = false
         //            row?.evaluateHidden()
         //            self.form.allSections.first?.reload(with: .none)
         //        }
         */
        form.allRows .forEach { (row) in
            row.reload()
            // row.updateCell()
        }
        
        if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func listCRs() {
        let listCRSection = self.form.sectionBy(tag: "list CR")!
        allChangeRequests?.forEach({ (changeReq) in
            listCRSection <<< CRArtisanRow() {
                $0.cell.height = { 50.0 }
                $0.cell.labelField.text = ChangeRequestType().searchChangeRequest(searchId: changeReq.requestItemsId)?.item ?? ""
                $0.cell.valuefield.text = changeReq.requestText ?? ""
                $0.cell.tickBtn.tag = changeReq.entityID
                $0.tag = changeReq.id
                $0.cell.isUserInteractionEnabled = false
                $0.cell.tickBtn.isUserInteractionEnabled = false
                if changeReq.requestStatus == 1 {
                    $0.cell.tickBtn.setImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
                    $0.cell.tickBtn.tintColor = UIColor().CEGreen()
                }else {
                    $0.cell.tickBtn.setImage(UIImage.init(systemName: "xmark.square.fill"), for: .normal)
                    $0.cell.tickBtn.tintColor = .red
                }
            }
        })
        self.form.sectionBy(tag: "list CR")?.reload()
    }
    
    func listTransactionsFunc() {
        if let listMOQSection = self.form.sectionBy(tag: "list Transactions") {
            let showTransactions = listTransactions!
            showTransactions.forEach({ (obj) in
                listMOQSection <<< TransactionTitleRowView() {
                    $0.cell.height = { 60.0 }
                    $0.cell.configure(obj)
                }.onCellSelection({ (cell, row) in
                    let row = self.form.rowBy(tag: obj.id!)
                    if row?.isHidden == true {
                        row?.hidden = false
                    }else {
                        row?.hidden = true
                    }
                    row?.evaluateHidden()
                    listMOQSection.reload()
                })
                    
                    <<< TransactionDetailRowView() {
                        $0.cell.height = { 60.0 }
                        $0.cell.configure(obj)
                        $0.cell.tag = obj.entityID
                        $0.cell.invoiceButton.tag = obj.entityID
                        $0.cell.delegate = self as TransactionListProtocol
                        $0.hidden = true
                        $0.tag = obj.id
                    }.onCellSelection({ (cell, row) in
                        if let obj = Enquiry().searchEnquiry(searchId: obj.enquiryId ) {
                            self.goToEnquiry?(obj.enquiryId)
                        }else {
                            self.downloadEnquiry?(obj.enquiryId )
                        }
                        
                    })
            })
        }
        self.form.sectionBy(tag: "list Transactions")?.reload()
    }
}
/*
 extension OrderDetailController:  InvoiceButtonProtocol{
 
 //} ConfirmDeliveryProtocol {
 /*
 func ConfirmDeliveryInitationBtnSelected(tag: Int) {
 switch tag {
 case 100:
 if orderObject != nil {
 let storyboard = UIStoryboard(name: "Payment", bundle: nil)
 let vc1 = storyboard.instantiateViewController(withIdentifier: "ConfirmOrderReceivedController") as! ConfirmOrderReceivedController
 vc1.orderObject = self.orderObject
 
 vc1.modalPresentationStyle = .fullScreen
 self.navigationController?.pushViewController(vc1, animated: true)
 
 }
 default:
 print("do nothing")
 }
 }*/
 
 
 //    func approvePaymentButtonSelected(tag: Int) {
 //        switch tag{
 //        case 3:
 //            let storyboard = UIStoryboard(name: "Payment", bundle: nil)
 //            let vc1 = storyboard.instantiateViewController(withIdentifier: "PaymentArtistController") as! PaymentArtistController
 //            vc1.orderObject = self.orderObject
 //            vc1.modalPresentationStyle = .fullScreen
 //            self.navigationController?.pushViewController(vc1, animated: true)
 //
 //        default:
 //            print("PaymentArtistBtnSelected Not WORKING")
 //        }
 //    }
 //
 //    func viewInvoiceButtonSelected(tag: Int) {
 //        switch tag{
 //        case 3:
 //            self.showLoading()
 //            self.viewPI?(0)
 //        default:
 //            print("do nothing")
 //        }
 //    }
 
 /*
 func createSendInvoiceBtnSelected(tag: Int) {
 switch tag{
 case 100:
 let client = try! SafeClient(wrapping: CraftExchangeClient())
 let vc1 = EnquiryDetailsService(client: client).piCreate(enquiryId: self.orderObject!.enquiryId, enquiryObj: nil, orderObj: self.orderObject) as! InvoiceController
 vc1.modalPresentationStyle = .fullScreen
 //  if orderObject?.enquiryStageId ?? 0 >= 3 {
 vc1.isFI = true
 vc1.PI = self.PI
 //                vc1.advancePaymnet = self.advancePaymnet
 //  }
 //            if self.orderObject?.productStatusId == 2 && orderObject?.enquiryStageId == 3{
 //                vc1.PI = self.PI
 //            }
 vc1.orderObject = self.orderObject
 print("PI WORKING")
 self.navigationController?.pushViewController(vc1, animated: true)
 print("createSendInvoiceBtnSelected WORKING")
 case 101:
 let client = try? SafeClient(wrapping: CraftExchangeClient())
 let vc1 = EnquiryDetailsService(client: client!).createPaymentScene(enquiryId: self.orderObject!.enquiryId) as! PaymentUploadController
 vc1.orderObject = self.orderObject
 vc1.modalPresentationStyle = .fullScreen
 self.navigationController?.pushViewController(vc1, animated: true)
 case 102:
 if finalPaymnetDetails != nil {
 let client = try? SafeClient(wrapping: CraftExchangeClient())
 let vc1 = EnquiryDetailsService(client: client!).createPaymentScene(enquiryId: self.orderObject!.enquiryId) as! PaymentUploadController
 vc1.orderObject = self.orderObject
 vc1.finalPaymnetDetails = self.finalPaymnetDetails
 vc1.viewModel.totalAmount.value = "\(self.finalPaymnetDetails!.totalAmount)"
 vc1.viewModel.paidAmount.value = "\(self.finalPaymnetDetails!.payableAmount)"
 vc1.viewModel.pid.value = "\(self.finalPaymnetDetails!.pid)"
 vc1.viewModel.percentage.value = "0"
 vc1.viewModel.invoiceId.value = "\(self.finalPaymnetDetails!.invoiceId)"
 vc1.modalPresentationStyle = .fullScreen
 self.navigationController?.pushViewController(vc1, animated: true)
 }
 case 103:
 if finalPaymnetDetails != nil {
 let storyboard = UIStoryboard(name: "Payment", bundle: nil)
 let vc1 = storyboard.instantiateViewController(withIdentifier: "PaymentArtistController") as! PaymentArtistController
 vc1.orderObject = self.orderObject
 vc1.finalPaymnetDetails = self.finalPaymnetDetails
 vc1.modalPresentationStyle = .fullScreen
 self.navigationController?.pushViewController(vc1, animated: true)
 
 }
 case 104:
 self.view.showMarkAsDispatchedView(controller: self)
 
 case 105:
 self.view.showCloseOrderView(controller: self, enquiryCode: orderObject?.orderCode, confirmStatement: "You are about to close this order!".localized)
 
 case 106:
 self.view.showPartialRefundReceivedView(controller: self, enquiryCode: orderObject?.orderCode, confirmQuestion: "Is Partial Refund Received?".localized)
 case 107:
 print("NOt Working PI")
 self.view.showPartialRefundReceivedView(controller: self, enquiryCode: orderObject?.orderCode, confirmQuestion: "Are you sure you want to recreate order?".localized)
 case 108:
 self.view.showMarkAsDispatchedView(controller: self)
 default:
 print("NOt Working PI")
 }
 }
 */
 //    func singleButtonSelected(tag: Int) {
 //        switch tag {
 //        case 101:
 //            self.showLoading()
 //            self.sendMOQ?()
 //        default:
 //            print("do nothing")
 //        }
 //    }
 
 //    func detailsButtonSelected(tag: Int) {
 //        let showMOQ = listMOQs!
 //        showMOQ.forEach({ (obj) in
 //            switch tag {
 //
 //            case obj.artisanId :
 //                let vc = CustomMOQArtisanDetailsController.init(style: .plain)
 //                vc.orderObject = self.orderObject
 //                vc.getMOs = obj
 //                self.navigationController?.pushViewController(vc, animated: true)
 //                print(obj.artisanId)
 //            default:
 //                print("do nothing")
 //            }
 //
 //        })
 //
 //    }
 
 //    func quantityButtonSelected(tag: Int) {
 //        switch tag {
 //        case 201:
 //            print("do nothing")
 //        default:
 //            print("do nothing")
 //        }
 //    }
 
 //    func priceButtonSelected(tag: Int) {
 //        switch tag {
 //        case 201:
 //            print("do nothing")
 //        default:
 //            print("do nothing")
 //        }
 //    }
 
 //    func ETAButtonSelected(tag: Int) {
 //        switch tag {
 //        case 201:
 //            print("do nothing")
 //        default:
 //            print("do nothing")
 //        }
 //    }
 
 }
 */
extension OrderDetailController: AcceptedPIViewProtocol { //, CloseOrderViewProtocol, MarkAsDispatchedViewProtocol, PartialRefundReceivedViewProtocol, ProvideRatingButtonProtocol  {
    /*
     /// provide rating
     func provideRatingButtonSelected(tag: Int) {
     switch tag {
     case 101:
     if self.orderObject != nil && self.isBuyerRatingDone != nil && self.isArtisanRatingDone != nil{
     do {
     let client = try SafeClient(wrapping: CraftExchangeClient())
     let vc = OrderDetailsService(client: client).createProvideRatingScene(forOrder: orderObject, enquiryId: orderObject?.enquiryId ?? 0) as! ProvideRatingController
     vc.orderObject = self.orderObject
     // vc.isBuyerRatingDone = self.isBuyerRatingDone
     // vc.isArtisanRatingDone = self.isArtisanRatingDone
     self.navigationController?.pushViewController(vc, animated: false)
     }catch {
     print(error.localizedDescription)
     }
     }
     default:
     print("do nothing")
     }
     }
     
     /// is partisal refund received
     func RefundCancelButtonSelected() {
     self.view.hidePartialRefundReceivedView()
     self.viewWillAppear?()
     }
     
     func RefundNoButtonSelected() {
     self.view.hidePartialRefundReceivedView()
     self.viewWillAppear?()
     }
     
     func RefundYesButtonSelected() {
     if  User.loggedIn()?.refRoleId == "2" {
     let client = try! SafeClient(wrapping: CraftExchangeClient())
     let service = EnquiryDetailsService.init(client: client)
     self.showLoading()
     if orderObject?.enquiryId != nil {
     service.completeOrder(enquiryId: orderObject!.enquiryId, vc: self)
     }
     }
     if User.loggedIn()?.refRoleId == "1" {
     self.recreateOrder?()
     }
     }*/
    
    /// mark as dispatched
    func MarkAsDipatchedCloseButtonSelected() {
        self.view.hideMarkAsDispatchedView()
    }
    
    func MarkAsDispatchedButtonSelected() {
        /*self.showLoading()
         if orderObject?.enquiryStageId == 9 {
         let client = try! SafeClient(wrapping: CraftExchangeClient())
         let service = EnquiryDetailsService.init(client: client)
         service.changeInnerStageFunc(vc: self, enquiryId: orderObject?.enquiryId ?? 0, stageId: 10, innerStageId: 0)
         }
         if orderObject?.isReprocess == 1{
         self.orderDispatchAfterRecreation?()
         }
         */
    }
    
    ///close order
    func closeOrderCancelButtonSelected() {
        self.view.hideCloseOrderView()
    }
    
    func closeOrderNoButtonSelected() {
        self.view.hideCloseOrderView()
    }
    
    func closeOrderYesButtonSelected() {
        /*let client = try! SafeClient(wrapping: CraftExchangeClient())
         let service = EnquiryDetailsService.init(client: client)
         self.showLoading()
         if orderObject?.enquiryId != nil {
         service.closeOrder(enquiryId: orderObject!.enquiryId,enquiryCode: orderObject?.enquiryCode ?? "", productStatusId: orderObject?.productStatusId ?? 0, vc: self)
         }*/
    }
    
    /// view PI
    func viewProformaInvoiceBtnSelected(tag: Int) {
        self.showLoading()
        self.viewPI?(0)
    }
    
    func viewOldPI() {
        self.showLoading()
        self.viewPI?(1)
    }
    
    func raiseNewPI() {
        self.view.hideAcceptedPIView()
        self.raiseNewCRPI?()
    }
    /*
     //    func RejectBtnSelected(tag: Int) {
     //        print("do nothing")
     //    }
     ///final payment
     func paymentBtnSelected(tag: Int) {
     switch tag{
     case 100:
     if self.orderObject?.isBlue ?? false || self.orderObject?.enquiryStageId ?? 0 >= 4{
     let client = try? SafeClient(wrapping: CraftExchangeClient())
     let vc1 = EnquiryDetailsService(client: client!).createPaymentScene(enquiryId: self.orderObject!.enquiryId) as! PaymentUploadController
     vc1.orderObject = self.orderObject
     vc1.modalPresentationStyle = .fullScreen
     self.navigationController?.pushViewController(vc1, animated: true)
     }
     else{
     let storyboard = UIStoryboard(name: "Payment", bundle: nil)
     let vc1 = storyboard.instantiateViewController(withIdentifier: "PaymentBuyerOneController") as! PaymentBuyerOneController
     vc1.orderObject = self.orderObject
     vc1.PI = self.PI
     vc1.modalPresentationStyle = .fullScreen
     self.navigationController?.pushViewController(vc1, animated: true)
     print("uploadReceiptBtnSelected")
     }
     default:
     print("uploadReceiptBtnSelected Not WORKING")
     }
     }
     */
    func backButtonSelected() {
        self.view.hideAcceptedPIView()
    }
    
    func downloadButtonSelected(isOld: Bool) {
        //   let view = self.view.
        self.downloadPI?(true, isOld)
    }
    
    func TIdownloadButtonSelected() {
        self.downloadPI?(false, false)
    }
    
    
    //    func cancelButtonSelected() {
    //        self.view.hideAcceptMOQView()
    //    }
    
    //    func acceptMOQButtonSelected() {
    //        self.showLoading()
    //        self.acceptMOQ?()
    //    }
    
    ///go to chat
    func enquiryChatButtonSelected() {
        self.goToChat()
    }
    
    //    func okButtonSelected() {
    //        self.reloadBuyerMOQ()
    //        self.form.allSections.first?.reload(with: .none)
    //        self.view.hideAcceptedMOQView()
    //        viewWillAppear?()
    //    }
    
}
/*
 extension OrderDetailController: MarkCompleteAndNextProtocol, StartstageProtocol {
 
 
 func MarkProgressSelected(tag: Int) {
 self.showLoading()
 let client = try! SafeClient(wrapping: CraftExchangeClient())
 let service = EnquiryDetailsService.init(client: client)
 service.changeInnerStageFunc(vc: self, enquiryId: orderObject?.enquiryId ?? 0, stageId: orderObject?.enquiryStageId ?? 0, innerStageId: orderObject?.innerEnquiryStageId ?? 0)
 }
 
 func MarkCompleteNextSelected(tag: Int) {
 self.showLoading()
 let client = try! SafeClient(wrapping: CraftExchangeClient())
 let service = EnquiryDetailsService.init(client: client)
 if orderObject?.innerEnquiryStageId == 5 {
 service.changeInnerStageFunc(vc: self, enquiryId: orderObject?.enquiryId ?? 0, stageId: 6, innerStageId: 0)
 }
 else{
 if let innerStageId = orderObject?.innerEnquiryStageId, innerStageId > 0 {
 service.changeInnerStageFunc(vc: self, enquiryId: orderObject?.enquiryId ?? 0, stageId: orderObject?.enquiryStageId ?? 0, innerStageId: innerStageId + 1)
 }
 }
 
 }
 
 func StartstageBtnSelected(tag: Int) {
 self.showLoading()
 let client = try! SafeClient(wrapping: CraftExchangeClient())
 let service = EnquiryDetailsService.init(client: client)
 service.changeInnerStageFunc(vc: self, enquiryId: orderObject?.enquiryId ?? 0, stageId: 5, innerStageId: 1)
 }
 
 
 }
 */
extension OrderDetailController: TransactionListProtocol, TransactionReceiptViewProtocol {
    func viewTransactionReceipt(tag: Int) {
        
        let showMOQ = listTransactions!
        showMOQ.forEach({ (obj) in
            print(obj)
            switch tag {
            case obj.entityID:
                print(obj)
                let invoiceStateArray = [1,2,3,4,5]
                let advancePaymentArray = [6,8,10]
                let taxInvoiceArray = [12,13]
                let finalPaymentarray = [14,16,18]
                let deliveryReciptArray = [20]
                if invoiceStateArray.contains(obj.accomplishedStatus) {
                    self.viewTransactionReceipt?(obj, 0, true)
                }else if advancePaymentArray.contains(obj.accomplishedStatus){
                    self.downloadAdvReceipt?(obj.enquiryId)
                }
                else if finalPaymentarray.contains(obj.accomplishedStatus){
                    self.downloadFinalReceipt?(obj.enquiryId)
                }else if taxInvoiceArray.contains(obj.accomplishedStatus) {
                    self.viewTransactionReceipt?(obj, 0, false)
                }
                else if deliveryReciptArray.contains(obj.accomplishedStatus) {
                    if self.orderObject != nil {
                        self.showLoading()
                        self.downloadDeliveryReceipt?(obj.enquiryId, "")
                    }
                }
            default:
                print("do nothing")
                
            }
        })
        
    }
    
    
    func cancelBtnSelected() {
        self.view.hideTransactionReceiptView()
    }
}

