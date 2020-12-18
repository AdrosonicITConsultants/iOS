//
//  RevisedPaymentUploadController.swift
//  CraftExchange
//
//  Created by Kalyan on 14/12/20.
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

class RevisedUploadPaymentViewModel {
    var imageData = Observable<Data?>(nil)
    var fileName = Observable<String?>(nil)
    var paidAmount =  Observable<String?>(nil)
    var percentage = Observable<String?>(nil)
    var totalAmount = Observable<String?>(nil)
     var pid = Observable<String?>(nil)
}

class RevisedPaymentUploadController: FormViewController{
    
    var enquiryObject: Enquiry?
    var orderObject: Order?
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var isClosed = false
    var editEnabled = true
    var data : Data?
    var revisedPayment: RevisedAdvancedPayment?
    lazy var viewModel = RevisedUploadPaymentViewModel()
    var uploadReciept: ((_ typeId: Int) -> ())?
    var uploadDeliveryReciept: (() -> ())?
    var imageReciept: ((_ typeId: Int) -> ())?
    var receipt: PaymentArtist?
    var revisedAdvancePaymentId: Int = 0
    
    //    let parentVC = self.parent as? PaymentUploadController
    override func viewDidLoad() {
        super.viewDidLoad()
//        let client = try! SafeClient(wrapping: CraftExchangeClient())
//        let service = EnquiryDetailsService.init(client: client)
        imageReciept?(3)
        
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let accountDetails = realm?.objects(PaymentAccDetails.self).filter("%K == %@","userId",enquiryObject?.userId ?? orderObject?.userId ?? 0)
        
        let back = UIBarButtonItem(image: UIImage.init(systemName: "arrow.left"), style: .done, target: self, action: #selector(backSelected(_:)))
        back.tintColor = .darkGray
        self.navigationItem.leftBarButtonItem =  back
        
        form
            +++ Section()
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 200.0 }
                $0.cell.selectionStyle = .none
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                
                $0.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "Amount to be paid: " + "\(revisedPayment?.pendingAmount ?? 0)" : "NA"
               
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let date = orderObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
                }
            
                $0.loadRowImage(orderObject: orderObject, enquiryObject: enquiryObject)
            }.cellUpdate({ (cell, row) in
                cell.amountLbl.text = self.orderObject?.totalAmount != 0 ? "Amount to be paid: " + "\(self.revisedPayment?.pendingAmount ?? 0)" : "NA"
            })
            <<< LabelRow(){
                $0.title = "Upload the Payment Receipt to Confirm".localized
                if revisedAdvancePaymentId == 3 {
                    $0.hidden = true
                }
            }
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 50.0 }
                $0.cell.titleLbl.text = "Brand: \(enquiryObject?.brandName ?? orderObject?.brandName ?? "NA")"
               
                if revisedAdvancePaymentId == 3 {
                    $0.hidden = true
                }
                
                $0.cell.valueLbl.text = "Check Artisan's Payment details"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                $0.cell.titleLbl.textColor = UIColor().EQBlueText()
                $0.cell.valueLbl.textColor = UIColor().EQBlueText()
                $0.cell.arrow.image = UIImage.init(systemName: "chevron.down")
                $0.cell.arrow.tintColor = UIColor().EQBlueText()
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
            <<< AccountDetailsRow() {
                $0.tag = "AccountDetails"
                $0.cell.height = {80.0}
                var nameString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        nameString = account.name ?? ""
                    }
                })
                $0.cell.AccountTitleLabel.text = "Account Details: \(nameString)"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 2 {
                        valueString = "\(account.bankName ?? ""), \(account.branchName ?? ""), Account No:  \(account.AccNoUpiMobile ?? ""), IFSC Code: \(account.ifsc ?? "")"
                    }
                })
                cell.AccountDetailLabel.text = valueString
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
            
            <<< uploadRecieptRow("uploadReceipt") {
                $0.cell.height = { 375.0 }
                $0.tag = "uploadReceipt"
                $0.cell.delegate = self
                if revisedAdvancePaymentId == 3 {
                    $0.hidden = true
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
                $0.cell.PleaseNoteLabel.text = "Please Note: The Proforma Invoice will be updated"
                $0.cell.EnquiryLabel.isHidden = true
                if revisedAdvancePaymentId == 3 {
                    $0.hidden = false
                    
                }
                
        }
    }
    
    @objc func backSelected(_ sender: Any) {
        
        var orderVC: OrderDetailController?
        self.navigationController?.viewControllers .forEach({ (controller) in
            if controller.isKind(of: OrderDetailController.self) {
                orderVC = controller as? OrderDetailController
            }
        })
        if let ordervc = orderVC {
            self.navigationController?.popToViewController(ordervc, animated: true)
        }
        
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "uploadReceipt")
        row?.reload()
        
    }
}

extension RevisedPaymentUploadController: uploadtransactionProtocol, uploadSuccessProtocol, TransactionReceiptViewProtocol {
    
    func cancelBtnSelected() {
        self.view.hideTransactionReceiptView()
    }
    
    func ViewTransactionBtnSelected(tag: Int) {
        showLoading()
        
        imageReciept?(3)
        
        if self.data != nil{
            self.view.showTransactionReceiptView(controller: self, data: self.data!)
        }
        
        self.hideLoading()
    }
    
    func UploadBtnSelected(tag: Int) {
        self.showLoading()
        self.uploadReciept?(3)
        
    }
    
    func UploadImageBtnSelected(tag: Int) {
        self.showImagePickerAlert()
    }
    
}

extension RevisedPaymentUploadController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        if enquiryObject?.enquiryStageId == 3{
            self.viewModel.fileName.value = "\(self.enquiryObject?.enquiryId ?? self.orderObject?.enquiryId ?? 0).\(self.enquiryObject?.enquiryId ?? self.orderObject?.enquiryId ?? 0).\(Int(self.viewModel.pid.value!)!).jpg"
        }
        if orderObject != nil{
            
            if orderObject!.enquiryStageId >= 9 && orderObject?.deliveryChallanUploaded != 1{
                if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    self.viewModel.fileName.value = url.lastPathComponent
                }
                
            }else{
                self.viewModel.fileName.value = "\(self.enquiryObject?.enquiryId ?? self.orderObject?.enquiryId ?? 0).\(self.enquiryObject?.enquiryId ?? self.orderObject?.enquiryId ?? 0).\(Int(self.viewModel.pid.value!)!).jpg"
            }
            
        }
        
        
        picker.dismiss(animated: true) {
            self.reloadAddPhotoRow()
        }
    }
}

