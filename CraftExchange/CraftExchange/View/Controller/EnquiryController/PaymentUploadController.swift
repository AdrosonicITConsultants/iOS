//
//  PaymentUploadController:.swift
//  CraftExchange
//
//  Created by Kiran Songire on 28/09/20.
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
import ImageRow
import ViewRow
import WebKit

class UploadPaymentViewModel {
    var imageData = Observable<Data?>(nil)
    var fileName = Observable<String?>(nil)
    var paidAmount =  Observable<String?>(nil)
    var percentage = Observable<String?>(nil)
    var totalAmount = Observable<String?>(nil)
    var pid = Observable<String?>(nil)
    var invoiceId = Observable<String?>(nil)
    var orderDispatchDate = Observable<String?>(nil)
    var ETA = Observable<String?>("0")
}

class PaymentUploadController: FormViewController{
    
    var enquiryObject: Enquiry?
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var isClosed = false
    var editEnabled = true
    var data : Data?
    var finalPaymnet: PaymentStatus?
    var finalPaymnetDetails: FinalPaymentDetails?
    lazy var viewModel = UploadPaymentViewModel()
    var uploadReciept: ((_ typeId: Int) -> ())?
    var uploadDeliveryReciept: (() -> ())?
    var imageReciept: ((_ typeId: Int) -> ())?
    var tobePaidAmount: String?
    var receipt: PaymentArtist?
    //    let parentVC = self.parent as? PaymentUploadController
    override func viewDidLoad() {
        super.viewDidLoad()
        if orderObject?.enquiryStageId == 8{
           imageReciept?(2)
        }else{
            imageReciept?(1)
        }
        
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let accountDetails = realm?.objects(PaymentAccDetails.self).filter("%K == %@","userId",enquiryObject?.userId ?? orderObject?.userId ?? 0)
        
        form
            +++ Section()
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                $0.cell.statusLbl.text = "10 days remaining to upload receipt"
                if orderObject != nil {
                    if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                        $0.cell.statusLbl.text = ""
                       // $0.cell.height = { 160.0 }

                    }
                }
                
                $0.cell.statusLbl.textColor = UIColor.black
                $0.cell.statusDotView.isHidden = true
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if enquiryObject?.productType ?? orderObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = enquiryObject?.brandName ?? orderObject?.brandName
                }
                //print(tobePaidAmount)
//                "
                
                if orderObject?.enquiryStageId == 8{
                    $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "Amount to be paid: " + "\(finalPaymnetDetails?.payableAmount ?? 0)" : "NA"
                }else{
                    $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "Amount to be paid: " + (tobePaidAmount ?? "NA") : "NA"
                }
                
                 if orderObject != nil {
                 if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                    $0.cell.amountLbl.text = ""
                }
                }
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let date = orderObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
                }
                 if orderObject != nil {
                 if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                    $0.cell.dateLbl.text = ""
                }
                }
                if let tag = enquiryObject?.productImages?.components(separatedBy: ",").first ?? orderObject?.productImages?.components(separatedBy: ",").first, let prodId = enquiryObject?.productId ?? orderObject?.productId {
                    if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        $0.cell.productImage.image = downloadedImage
                    }else {
                        do {
                            let client = try SafeClient(wrapping: CraftExchangeImageClient())
                            let service = ProductImageService.init(client: client)
                            service.fetch(withId: prodId, withName: tag).observeNext { (attachment) in
                                DispatchQueue.main.async {
                                    _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    let row = self.form.rowBy(tag: "EnquiryDetailsRow") as! EnquiryDetailsRow
                                    row.cell.productImage.image = UIImage.init(data: attachment)
                                    row.reload()
                                }
                            }.dispose(in: bag)
                        }catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
            <<< LabelRow(){
                $0.title = "Upload the Payment Receipt to Confirm".localized
                if enquiryObject?.isBlue ?? orderObject?.isBlue ?? false {
                    $0.hidden = true
                }
                 if orderObject != nil {
                 if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                    $0.title = "Upload the Delivery Receipt".localized
                }
                }
            }
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                if User.loggedIn()?.refRoleId == "2" {
                    $0.cell.titleLbl.text = "Brand: \(enquiryObject?.brandName ?? orderObject?.brandName ?? "NA")"
                }else {
                    $0.cell.titleLbl.text = ""
                }
                if enquiryObject?.isBlue ?? orderObject?.isBlue ?? false {
                    $0.hidden = true
                }
                if orderObject != nil {
                if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1 {
                         $0.hidden = true
                    }
                }
                $0.cell.valueLbl.text = "Check Artisn's Payment details"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                $0.cell.titleLbl.textColor = UIColor().EQBlueText()
                $0.cell.valueLbl.textColor = UIColor().EQBlueText()
            }.onCellSelection({ (cell, row) in
                let row1 = self.form.rowBy(tag: "AccountDetails")
                let row2 = self.form.rowBy(tag: "Gpay")
                let row3 = self.form.rowBy(tag: "Paytm")
                let row4 = self.form.rowBy(tag: "PhonePay")
                
                if row1?.isHidden == true {
                    row1?.hidden = false
                    row2?.hidden = false
                    row3?.hidden = false
                    row4?.hidden = false
                }else {
                    row1?.hidden = true
                    row2?.hidden = true
                    row3?.hidden = true
                    row4?.hidden = true
                }
                row1?.evaluateHidden()
                row2?.evaluateHidden()
                row3?.evaluateHidden()
                row4?.evaluateHidden()
                self.form.allSections.first?.reload(with: .none)
            })
            <<< TextRow() {
                $0.tag = "AccountDetails"
                $0.cell.height = { 40.0 }
                var nameString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        nameString = account.name ?? ""
                    }
                })
                $0.title = "Account Details: \(nameString)"
                
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.isUserInteractionEnabled = false
                cell.textField.layer.borderColor = UIColor.white.cgColor
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 2 {
                        valueString = "\(account.bankName ?? ""), \(account.branchName ?? ""), Account No:  \(account.AccNoUpiMobile ?? ""), IFSC Code: \(account.ifsc ?? "")"
                    }
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                })
                cell.textField.text = valueString
            })
            <<< PaymentModeRow() {
                $0.cell.height = { 50.0 }
                $0.tag = "Gpay"
                $0.cell.paymentIcon.image = UIImage.init(named: "gPayIcon")
                $0.cell.PaymentModeLbl.text = "Google Pay UPI Id"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 2 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.PaymentValueLbl.text = valueString
                $0.hidden = true
            }
            
            <<< PaymentModeRow() {
                $0.cell.height = { 50.0 }
                $0.tag = "Paytm"
                $0.cell.paymentIcon.image = UIImage.init(named: "paytmIcon")
                $0.cell.PaymentModeLbl.text = "Paytm Registered Mobile Number"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 4 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.PaymentValueLbl.text = valueString
                $0.hidden = true
            }
            
            <<< PaymentModeRow() {
                $0.cell.height = { 50.0 }
                $0.tag = "PhonePay"
                $0.cell.paymentIcon.image = UIImage.init(named: "phone-pe")
                $0.cell.PaymentModeLbl.text = "Resgistered Number for PhonePay"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 3 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.PaymentValueLbl.text = valueString
                $0.hidden = true
            }
            
            <<< DateRow(){
                            $0.title = "Date of dispatch"
                            $0.cell.height = { 60.0 }
                            $0.maximumDate = Date()
                if orderObject != nil {
                    if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                         $0.hidden = false
                    }else{
                        $0.hidden = true
                    }
                }
                            
                            $0.value = Date()
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                            let date = dateFormatter.string(from: $0.value!)
//                            self.viewModel.orderDispatchDate.value = date + " 10:00:00"
                        }.onChange({ (row) in
                            if let value = row.value {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                let date = dateFormatter.string(from: value)
                                self.viewModel.orderDispatchDate.value = date
                                //                    enquiry/submitDeliveryChallan?enquiryId=1881&orderDispatchDate=2020-10-27%2014%3A14%3A06&ETA=2020-10-27%2014%3A14%3A06
                            }
                        }).cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .black
                            cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                        })
                        
                        <<< DateRow(){
                            $0.title = "Revised ETA (if required)"
                            $0.cell.height = { 60.0 }
                            $0.minimumDate = Date()
                            
                            if orderObject != nil {
                                if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                                     $0.hidden = false
                                }else{
                                    $0.hidden = true
                                }
                            }

                            $0.value = nil
            //                let dateFormatter = DateFormatter()
            //                dateFormatter.dateFormat = "yyyy-MM-dd"
            //                let date = dateFormatter.string(from: $0.value!)
            //                self.viewModel.ETA.value = date + " 10:00:00"
                        }.onChange({ (row) in
                            if let value = row.value {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                let date = dateFormatter.string(from: value)
                                self.viewModel.ETA.value = date
                            }
                        }).cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .black
                            cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                        })
            
            <<< uploadRecieptRow("uploadReceipt") {
                $0.cell.height = { 375.0 }
                $0.tag = "uploadReceipt"
                $0.cell.delegate = self
                if enquiryObject?.isBlue ?? false || enquiryObject?.enquiryStageId ?? 0 >= 4{
                    $0.hidden = true
                }
                if enquiryObject?.enquiryStageId ?? 0 < 4{
                    $0.hidden = false
                }
                if orderObject?.isBlue ?? false || orderObject?.enquiryStageId ?? 0 >= 4{
                    $0.hidden = true
                }
                if orderObject?.enquiryStageId ?? 0 < 4{
                    $0.hidden = false
                }
                if orderObject?.enquiryStageId == 8 {
                    $0.hidden = false
                }
                if orderObject?.isBlue ?? false {
                    $0.hidden = true
                }
                if orderObject != nil{
                    if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                        $0.hidden = false
                        $0.cell.UploadBtn.setTitle("Upload delivery receipt", for: .normal)
                    }
                }
                 
            }

            
            <<< UploadSuccessfulRow("uploadsuccess") {
                $0.cell.height = { 375 }
                $0.tag = "uploadsuccess"
                $0.cell.delegate = self
                $0.cell.Tick.layer.cornerRadius = 30
                $0.cell.Tick.layer.borderColor = #colorLiteral(red: 0.2589518452, green: 0.5749325825, blue: 0.166714282, alpha: 1)
                $0.cell.Tick.layer.borderWidth = 2
                $0.hidden = true
                if enquiryObject?.isBlue ?? false || enquiryObject?.enquiryStageId ?? 0 >= 4{
                    $0.hidden = false
                }
                if orderObject?.isBlue ?? false || orderObject?.enquiryStageId ?? 0 >= 4{
                    $0.hidden = false
                }
                if orderObject?.enquiryStageId ?? 0 < 4{
                    $0.hidden = true
                }
                if orderObject?.enquiryStageId == 8 {
                   $0.hidden = true
                }
                if orderObject?.isBlue ?? false {
                    $0.hidden = false
                }
                if orderObject != nil{
                    if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                         $0.hidden = true
                    }
                }
                 
        }
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "uploadReceipt")
        row?.reload()
        
    }
}

extension PaymentUploadController: uploadtransactionProtocol, uploadSuccessProtocol, TransactionReceiptViewProtocol {
    
    func cancelBtnSelected() {
        self.view.hideTransactionReceiptView()
    }
    
    func ViewTransactionBtnSelected(tag: Int) {
        showLoading()
        if orderObject?.enquiryStageId == 8{
            imageReciept?(2)
        }else{
            imageReciept?(1)
        }
        if self.data != nil{
             self.view.showTransactionReceiptView(controller: self, data: self.data!)
        }
       
       self.hideLoading()
    }
    
    func UploadBtnSelected(tag: Int) {
        self.showLoading()
        if orderObject != nil {
        if orderObject?.enquiryStageId == 8 {
                     self.uploadReciept?(2)
                }else if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1 {
                    self.uploadDeliveryReciept?()
        //            print(self.viewModel.orderDispatchDate.value!)
                }else{
                     self.uploadReciept?(1)
                }
        }
        
    }
    
    func UploadImageBtnSelected(tag: Int) {
        self.showImagePickerAlert()
    }
    
}

extension PaymentUploadController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        let row = self.form.rowBy(tag: "uploadReceipt") as? uploadRecieptRow
        row?.cell.uploadImgBtn.setImage(selectedImage, for: .normal)
        row?.cell.uploadImgBtn.imageView?.layer.cornerRadius = 60
        
        var imgdata: Data?
        if let compressedImg = selectedImage.resizedTo1MB() {
            if let data = compressedImg.pngData() {
                imgdata = data
            } else if let data = compressedImg.jpegData(compressionQuality: 1) {
                imgdata = data
            }
        }else {
            if let data = selectedImage.pngData() {
                imgdata = data
            } else if let data = selectedImage.jpegData(compressionQuality: 0.5) {
                imgdata = data
            }
            
        }
        self.viewModel.imageData.value = imgdata
        if orderObject != nil{
           
            if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    self.viewModel.fileName.value = url.lastPathComponent
                }
                 
            }else{
                self.viewModel.fileName.value = "\(self.enquiryObject?.enquiryId ?? self.orderObject?.enquiryId ?? 0).\(Int(self.viewModel.pid.value!)!).jpg"
            }
            
        }
        
       
        picker.dismiss(animated: true) {
            self.reloadAddPhotoRow()
        }
    }
}
