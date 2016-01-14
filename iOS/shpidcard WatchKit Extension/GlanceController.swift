//
//  GlanceController.swift
//  shpidcard WatchKit Extension
//
//  Created by Dylan Modesitt on 8/31/15.
//  Copyright (c) 2015 Dylan Modesitt. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import UIKit


class GlanceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var barcode: WKInterfaceImage!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var barcodeImage: UIImage?
    
    var session : WCSession!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
    }
    
    override func willActivate() {
        super.willActivate()
        startSession()
        if let barcodeStored = defaults.objectForKey("barcode") as! NSData? {
            dispatch_async(dispatch_get_main_queue()) {
                // I had to do this weird double casting to get it to compile... I dont know why
                let value =  barcodeStored as NSData?
                let decodedImage =  value.map({UIImage(data: $0)})
                self.barcode.setImage(decodedImage!)
                self.label .setText("SHPID:")
                self.sendCheck()
            }
            
        } else {
            self.label .setText("SHPID")
            sendMessage()
        }
    }
    
    func startSession() {
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    func sendMessage() {
        let messageToSend = ["Value":"Hello iPhone"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let value = replyMessage["Value"] as? NSData
            self.defaults.setObject(value,forKey: "barcode")
            dispatch_async(dispatch_get_main_queue()) {
                let decodedImage =  value.map({UIImage(data: $0)})
                if let image = decodedImage {
                    self.barcode.setImage(image)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.label.setText("Please setup SHPID extensions in the settings of the app.")
                    }
                }
            }}, errorHandler: {error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.label.setText("Please setup SHPID extensions in the settings of the app.")
                }
                //print(error)
        })
    }
    
    func sendCheck() {
        let messageToSend = ["Value":"Roger"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let value = replyMessage["Value"] as? String
            if value == "yes" {
                self.sendMessage()
            }
            
            }, errorHandler: {error in
                //print(error)
        })
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
}
