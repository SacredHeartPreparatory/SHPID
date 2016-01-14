//
//  IDViewController.swift
//  SHP ID APP
//
//  Created by Dylan Modesitt on 4/2/15.
//  Copyright (c) 2015 Dylan Modesitt. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import AVFoundation
import CoreData
import WatchConnectivity

class IDViewController: UIViewController, WCSessionDelegate {
    
    // MARK: Variables
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var logo: UIImageView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    // Shared App Group For Extensions
    var defaultsShared = NSUserDefaults(suiteName: "group.org.shschools.shpidcard.shared")
    
    // Keep track of how many times SHPID has been loaded
    var initialLoad = Bool()
    
    private var barcodeImage: UIImage? {
        var barcodeGenerated: UIImage?
        if let barcodeString = defaultsShared!.objectForKey("barcode") as? String {
            if let barcodeContent = RSUnifiedCodeGenerator.shared.generateCode(barcodeString, machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code) {
                barcodeGenerated = barcodeContent
            } else {
                barcodeGenerated = nil
            }}
        return barcodeGenerated
    }
    
    struct ValidationQueue {
        static var queue = NSOperationQueue()
    }
    
    // MARK: View Controller Lifecycle
    
    
    override func viewDidAppear(animated: Bool) {
        loadIDCard()
        openSession()
    }
    
    // MARK: Methods
    
    
    private func loadIDCard() {
        hideFailureImage()
        let usercode:String! = NSUserDefaults.standardUserDefaults().stringForKey("code")
        // This is the only URL that needs to be changed in order for the right url to be loaded by the Web View
        let urlGiven:String! = "http://web.shschools.org/shpid/pdfs/\(usercode).pdf"
        if usercode == nil {self.presentSetupController(); return}
        
        let url = NSURL(string: urlGiven)
        let request = NSURLRequest(URL: url!)
        
        if let validatedUrl = NSURL(string: urlGiven) {
            // Send URL request that returns only the header response of the HTML page
            let request = NSMutableURLRequest(URL: validatedUrl)
            request.HTTPMethod = "HEAD"
            ValidationQueue.queue.cancelAllOperations()
            checkForLostCode(request)
        }
        checkForInitialLoad()
        dispatch_async(dispatch_get_main_queue(), {
            self.webView!.loadRequest(request)
        })
    }
    
    private func presentSetupController() {
        var tField: UITextField!
        func configurationTextField(textField: UITextField!){
            textField.placeholder = "SHPID Code"
            textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            tField = textField
        }
        
        func handleCancel(alertView: UIAlertAction!){self.performSegueWithIdentifier("Request", sender: self)}
        
        let alert = UIAlertController(title: "SHPID Code", message: "SHPID will allow you to have your Sacred Heart Prep ID on your device. SHPID uses unique, 8-digit, alphanumeric codes to secure your ID. An email with your code should probably be in your inbox. If not, you can request one. Please enter a valid SHPID Code.", preferredStyle: UIAlertControllerStyle.Alert)
        initialLoad = true
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Request Code", style: UIAlertActionStyle.Destructive, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            
            if let studentCode = tField.text {
                let allowedCharacters = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
                allowedCharacters.removeCharactersInString("+/=")
                
                if let cleanedString = studentCode.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject((cleanedString.uppercaseString), forKey: "code")
                    self.loadIDCard()
                } else { self.loadIDCard()}
            } else {self.loadIDCard()}}))
        self.presentViewController(alert, animated: true, completion: {})
    }
    
    private func presentExtentionsController() {
        var tField: UITextField!
        func configurationTextField(textField: UITextField!){
            textField.placeholder = "Student ID Number"
            textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            tField = textField
        }
        
        func handleCancel(alertView: UIAlertAction!){}
        
        let alert = UIAlertController(title: "SHPID Extensions", message: "Please enter your ID # to use SHPID Extensions in the Notification Center and on the Apple Watch. This is found on your ID card.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Sumbit", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            if let barcode = tField.text {
                if barcode != self.defaults.objectForKey("code") as! String && barcode.isEmpty == false {
                    self.defaultsShared?.setObject(barcode, forKey: "barcode")
                    let alert = UIAlertView()
                    alert.title = "Extensions"
                    alert.message = "You can now use extensions with SHPID. If you need to change your ID number, it can be done in settings."
                    alert.addButtonWithTitle("Ok")
                    alert.show()
                } else if barcode.isEmpty {
                    let alert = UIAlertView()
                    alert.title = "Extensions"
                    alert.message = "ERROR! Please enter a non-empty ID number."
                    alert.addButtonWithTitle("Ok")
                    alert.show()
                    self.presentExtentionsController()
                } else {
                    let alert = UIAlertView()
                    alert.title = "Extensions"
                    alert.message = "ERROR! Please enter your ID number, not your SHPID code."
                    alert.addButtonWithTitle("Ok")
                    alert.show()
                    self.presentExtentionsController()
                }
                
            }}))
        self.presentViewController(alert, animated: true, completion: {})
    }
    
    private func showFailureImage() {
        dispatch_async(dispatch_get_main_queue(), {
            self.webView.hidden = true
            self.logo.hidden = false
        })
    }
    
    private func hideFailureImage() {
        dispatch_async(dispatch_get_main_queue(), {
            self.webView.hidden = false
            self.logo.hidden = true
        })
    }
    
    
    func openSession() {
        if #available(iOS 9.0, *) {
            var session: WCSession
            if (WCSession.isSupported()) {
                session = WCSession.defaultSession()
                session.delegate = self;
                session.activateSession()
            }
            
        } else {
            // Watchkit session is unavalibale
        }
    }
    
    
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //handle received message
        let hasChanged = defaults.boolForKey("hasChanged")
        let given = message["Value"] as? String
        //use this to present immediately on the screen
        dispatch_async(dispatch_get_main_queue()) {
            // update UI
        }
        let codedImage = UIImagePNGRepresentation(barcodeImage!)
        //print(given)
        //print(hasChanged)
        if given == "Hello iPhone" {
            replyHandler(["Value":codedImage!])
        } else if given == "Roger" {
            if hasChanged == true {
                replyHandler(["Value": "yes"])
                defaults.setBool(false, forKey: "hasChanged")
            } else {
                replyHandler(["Value": "no"])
            }
        } else {
            replyHandler(["Value":codedImage!])
        }
        
    }
    
    private func checkForLostCode(request: NSMutableURLRequest) {
        NSURLConnection.sendAsynchronousRequest(request, queue: ValidationQueue.queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            _ = request.URL!.absoluteString
            // The code has not been entered or is lost
            if (error != nil){return} else {}
            // Check Status Code
            if let urlResponse = response as? NSHTTPURLResponse{
                // 200-399 = Valid Responses
                if ((urlResponse.statusCode >= 200 && urlResponse.statusCode < 400)){
                    if let _: String = NSUserDefaults.standardUserDefaults().objectForKey("extensions") as? String {} else {
                        self.presentExtentionsController()
                        self.defaults.setObject("True", forKey: "extensions")
                    }
                } else {
                    self.showFailureImage()
                    let alertController = UIAlertController(title: "Error", message: "You don't seem to have the right code. Please set up SHPID correctly!", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in self.presentSetupController() }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {}
                    return
                }
            }
        })
    }
    
    private func checkForInitialLoad() {
        if initialLoad {
            if Reachability.isConnectedToNetwork() == false {
                dispatch_async(dispatch_get_main_queue(), {
                    self.webView.hidden = true
                    self.logo.hidden = false
                })
                let alertController = UIAlertController(title: "Error", message: "Please ensure you have a valid internet connection to setup SHPID initially.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.presentSetupController()
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                }
            }
        }
    }
    
    
}


