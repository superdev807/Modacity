//
//  IAPHelper.swift
//  Modacity
//
//  Created by BC Engineer on 25/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate {
    
    static let helper = IAPHelper()
    
    static let appNotificationProductInfoFetched = Notification.Name(rawValue: "appNotificationProductInfoFetched")
    static let appNotificationSubscriptionSucceeded = Notification.Name(rawValue: "appNotificationMonthlySubscriptionSucceeded")
    static let appNotificationSubscriptionFailed = Notification.Name(rawValue: "appNotificationSubscriptionFailed")
    
    let monthlySubscriptionId = AppConfig.devVersion ? "com.app.modacity.dev.premiumupgrade" : "com.app.modacity.premiumupgrade.monthly"
    let verifyReceiptUrl = AppConfig.production ? "http://buy.itunes.apple.com/verifyReceipt" : "https://sandbox.itunes.apple.com/verifyReceipt"
    let sharedSecret = AppConfig.devVersion ? "2ebbd4466faa4f2884c7a962f5d7435f" : "036db65cbeee4ebea98c40ebc6b6cd0c"
    
    var productIDs = [String]()
    var productsArray = [SKProduct]()
    
    var renewalStatus = false
    var validUntil: Date? = nil
    
    var restoring = false
    
    func requestProductInfo() {
        ModacityDebugger.debug("Started subscribe - \(monthlySubscriptionId)")
        productIDs = [monthlySubscriptionId]
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        } else {
            ModacityDebugger.debug("We cannot make payment")
            NotificationCenter.default.post(Notification(name: IAPHelper.appNotificationProductInfoFetched))
            NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Payment cannot be made!"])
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            productsArray = [SKProduct]()
            for product in response.products {
                productsArray.append(product)
            }
            NotificationCenter.default.post(Notification(name: IAPHelper.appNotificationProductInfoFetched))
            
            for product in productsArray {
                if product.productIdentifier == monthlySubscriptionId {
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(SKPayment(product: product))
                    return
                }
            }
        } else {
            ModacityDebugger.debug("not get any product!")
            NotificationCenter.default.post(Notification(name: IAPHelper.appNotificationProductInfoFetched))
            NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Failed in fetching product info!"])
        }
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    
    func subscribe() {
        restoring = false
        self.requestProductInfo()
    }
    
    func restore() {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            ModacityDebugger.debug("We cannot restore payment")
            NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Cannot restore payment!"])
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        ModacityDebugger.debug("Restore failed.")
        NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Restore failed."])
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                ModacityDebugger.debug("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.receiptValidation()
            case .failed:
                ModacityDebugger.debug("Transaction failed.")
                SKPaymentQueue.default().finishTransaction(transaction)
                NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Transaction failed."])
            case .restored:
                ModacityDebugger.debug("Transaction restored.")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.receiptValidation()
            default:
                ModacityDebugger.debug("\(transaction.transactionState.rawValue)")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        ModacityDebugger.debug("Restore completed successfully.")
        self.receiptValidation()
    }
    
    func receiptValidation() {
        
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                ModacityDebugger.debug("Receipt String - \(receiptString)")
                self.receiptValidation(receiptString: receiptString, completion: {(error, autorenewal, validUntil) in
                    if let error = error {
                        NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": error])
                    } else {
                        if var validUntil = validUntil {
                            if appStoreReceiptURL.lastPathComponent == "sandboxReceipt" {
                                validUntil = validUntil.advanced(years: 0, months: 1, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
                            }
                            PremiumDataManager.manager.registerSubscription(key: receiptString, until: validUntil, completion: { (error) in
                                if let _ = error {
                                    NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Failed to synchronize to server."])
                                } else {
                                    NotificationCenter.default.post(Notification(name: IAPHelper.appNotificationSubscriptionSucceeded))
                                }
                            })
                        } else {
                            NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Failed to retrieve receipt expire date."])
                        }
                    }
                })
            } catch {
                NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Failed to parse receipt."])
            }
        } else {
            NotificationCenter.default.post(name: IAPHelper.appNotificationSubscriptionFailed, object: nil, userInfo: ["error": "Failed to retrieve receipt."])
        }
        
    }
}

extension IAPHelper {
    
    func receiptValidation(receiptString: String, completion: @escaping (String?, Bool, Date?)->()) {
        
        let dict = ["receipt-data" : receiptString, "password" : sharedSecret] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let receiptUrlLastPath = Bundle.main.appStoreReceiptURL?.lastPathComponent ?? ""
            print("receipt url last path - \(receiptUrlLastPath)")
            let receiptUrl = (receiptUrlLastPath != "sandboxReceipt") ? "http://buy.itunes.apple.com/verifyReceipt" : "https://sandbox.itunes.apple.com/verifyReceipt"
            if let sandboxURL = Foundation.URL(string:receiptUrl) {
                var request = URLRequest(url: sandboxURL)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: request) { data, response, error in
                    if let receivedData = data,
                        let httpResponse = response as? HTTPURLResponse,
                        error == nil,
                        httpResponse.statusCode == 200 {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> {
                                
                                print("receipt data =============================")
                                print(String(data: receivedData, encoding: .utf8) ?? "")
                                if let pendingRenewalInfo = jsonResponse["pending_renewal_info"] as? [[String:Any]] {
                                    if pendingRenewalInfo.count > 0 {
                                        let autoRenewStatus = pendingRenewalInfo[0]["auto_renew_status"] as? String ?? "0"
                                        self.renewalStatus = (autoRenewStatus == "1")
                                    }
                                }
                                
                                if let lastReceiptInfo = jsonResponse["latest_receipt_info"] as? [[String:Any]] {
                                    if let last = lastReceiptInfo.last {
                                        if let expiresDateString = last["expires_date_ms"] as? String {
                                            self.validUntil = Date(timeIntervalSince1970: (Double(expiresDateString) ?? 0) / 1000)
                                            
                                            if let validUntil = self.validUntil {
                                                if receiptUrlLastPath == "sandboxReceipt" {
                                                    self.validUntil = validUntil.advanced(years: 0, months: 1, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
                                                }
                                            }
                                        }
                                    }
                                }
                                completion(nil, self.renewalStatus, self.validUntil)
                            } else {
                                completion("Failed to cast serialized JSON to Dictionary<String, AnyObject>", false, nil)
                            }
                        } catch {
                            completion("Couldn't serialize JSON with error: " + error.localizedDescription, false, nil)
                        }
                    } else {
                        completion("Failed to receive response from app store receipt.", false, nil)
                    }
                }
                task.resume()
            } else {
                completion("Couldn't convert string into URL. Check for special characters.", false, nil)
            }
        } catch {
            completion("Couldn't create JSON with error: " + error.localizedDescription, false, nil)
        }
        
    }
}

