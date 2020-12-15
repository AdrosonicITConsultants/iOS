//
//  EnquiryDetailsService.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class EnquiryDetailsService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    
    func getOpenEnquiryDetails(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.getOpenEnquiryDetails(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getClosedEnquiryDetails(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.getClosedEnquiryDetails(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func closeEnquiry(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.closeEnquiry(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func markOrderAsReceived(orderId: Int, orderRecieveDate: String, isAutoCompleted: Int)-> SafeSignal<Data> {
        return Enquiry.markOrderAsReceived(orderId: orderId, orderRecieveDate: orderRecieveDate, isAutoCompleted: isAutoCompleted).response(using: client).debug()
    }
    
    func closeOrder(enquiryId: Int) -> SafeSignal<Data> {
        return Enquiry.closeOrder(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getMOQs(enquiryId: Int) -> SafeSignal<Data>{
        return Enquiry.getMOQs(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getPI(enquiryId: Int) -> SafeSignal<Data>{
        return Enquiry.getPI(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getMOQ(enquiryId: Int) -> SafeSignal<Data>{
        return Enquiry.getMOQ(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func sendMOQ(enquiryId: Int, additionalInfo: String, deliveryTimeId: Int, moq: Int, ppu: String)-> SafeSignal<Data>  {
        return Enquiry.sendMOQ(enquiryId: enquiryId, additionalInfo: additionalInfo, deliveryTimeId: deliveryTimeId, moq: moq, ppu: ppu).response(using: client).debug()
    }
    
    func acceptMOQ(enquiryId: Int, moqId: Int, artisanId: Int)-> SafeSignal<Data> {
        return Enquiry.acceptMOQ(enquiryId: enquiryId, moqId: moqId, artisanId: artisanId).response(using: client).debug()
    }
    
    func getPreviewPI(enquiryId: Int, isOld: Int) -> SafeSignal<Data>{
        return Enquiry.getPreviewPI(enquiryId: enquiryId, isOld: isOld).response(using: client).debug()
    }
    
    func getViewFI(enquiryId: Int, isOld: Int)  -> SafeSignal<Data>{
        return Enquiry.getViewFI(enquiryId: enquiryId, isOld: isOld).response(using: client).debug()
    }
    
    func downloadPI(enquiryId: Int, isOld: Int) -> SafeSignal<Data>{
        return Enquiry.downloadPreviewPI(enquiryId: enquiryId, isOld: isOld).response(using: client).debug()
    }
    
    func downloadTaxInvoice(enquiryId: Int, isOld: Int) -> SafeSignal<Data>{
        return Enquiry.downloadTaxInvoice(enquiryId: enquiryId, isOld: isOld).response(using: client).debug()
    }
    
    func savePI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int, ppu: Int, quantity: Int, sgst: Int )-> SafeSignal<Data>  {
        return Enquiry.savePI(enquiryId: enquiryId, cgst: cgst, expectedDateOfDelivery: expectedDateOfDelivery, hsn: hsn, ppu: ppu, quantity: quantity, sgst: sgst).response(using: client).debug()
    }
    
    func sendPI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int, ppu: Int, quantity: Int, sgst: Int )-> SafeSignal<Data>  {
        return Enquiry.sendPI(enquiryId: enquiryId, cgst: cgst, expectedDateOfDelivery: expectedDateOfDelivery, hsn: hsn, ppu: ppu, quantity: quantity, sgst: sgst).response(using: client).debug()
    }
    
    func previewFinalInvoice(enquiryId: String, advancePaidAmount: String, finalTotalAmount: Int, quantity: Int, ppu: Int, cgst: String , sgst: String, deliveryCharges: String )-> SafeSignal<Data>  {
        return Enquiry.previewFinalInvoice(enquiryId: enquiryId, advancePaidAmount: advancePaidAmount, finalTotalAmount: finalTotalAmount, quantity: quantity, ppu: ppu, cgst: cgst, sgst: sgst, deliveryCharges: deliveryCharges).response(using: client).debug()
    }
    
    func sendFinalInvoice(enquiryId: String, advancePaidAmount: String, finalTotalAmount: Int, quantity: Int, ppu: Int, cgst: String , sgst: String, deliveryCharges: String )-> SafeSignal<Data>  {
        return Enquiry.sendFinalInvoice(enquiryId: enquiryId, advancePaidAmount: advancePaidAmount, finalTotalAmount: finalTotalAmount, quantity: quantity, ppu: ppu, cgst: cgst, sgst: sgst, deliveryCharges: deliveryCharges).response(using: client).debug()
    }
    
    func uploadReceipt(enquiryId: Int, type: Int, paidAmount: Int, percentage: Int, invoiceId: Int, pid: Int, totalAmount: Int , imageData: Data, filename: String?)-> SafeSignal<Data>  {
        return Enquiry.uploadReceipt(enquiryId: enquiryId, type: type, paidAmount: paidAmount, percentage: percentage, invoiceId: invoiceId, pid: pid, totalAmount: totalAmount, imageData: imageData, filename: filename).response(using: client).debug()
    }
    
    func ImgReceit(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.ReceivedReceit(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func RevisedPaymentReceit(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.RevisedPaymentReceit(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func FinalPaymentReceit(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.FinalPaymentReceit(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getAdvancePaymentStatus(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.getAdvancePaymentStatus(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getRevisedAdvancePaymentStatus(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.getRevisedAdvancePaymentStatus(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getFinalPaymentDetails(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.getFinalPaymentDetails(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func getFinalPaymentStatus(enquiryId: Int)-> SafeSignal<Data>  {
        return Enquiry.getFinalPaymentStatus(enquiryId: enquiryId).response(using: client).debug()
    }
    
    func validateAdvancePayment(enquiryId: Int, status: Int)-> SafeSignal<Data>  {
        return Enquiry.validateAdvancePayment(enquiryId: enquiryId, status: status).response(using: client).debug()
    }
    
    func validateFinalPayment(enquiryId: Int, status: Int)-> SafeSignal<Data>  {
        return Enquiry.validateFinalPayment(enquiryId: enquiryId, status: status).response(using: client).debug()
    }
    
    func uploadDeliveryChallan(enquiryId: Int,orderDispatchDate: String, ETA: String, imageData: Data, filename: String)-> SafeSignal<Data>  {
        return Enquiry.uploadDeliveryChallan(enquiryId: enquiryId, orderDispatchDate: orderDispatchDate, ETA: ETA, imageData: imageData, filename: filename).response(using: client).debug()
    }
    
    func changeInnerStage(enquiryId: Int, stageId: Int, innerStageId: Int)-> SafeSignal<Data>  {
        return Enquiry.changeInnerStage(enquiryId: enquiryId, stageId: stageId, innerStageId: innerStageId).response(using: client).debug()
    }
    
}
