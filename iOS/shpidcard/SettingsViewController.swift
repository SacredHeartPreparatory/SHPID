//
//  SettingsViewController.swift
//  SHP ID APP
//
//  Created by Dylan Modesitt on 4/5/15.
//  Copyright (c) 2015 Dylan Modesitt. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class SettingsViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var defaultsShared = NSUserDefaults(suiteName: "group.org.shschools.shpidcard.shared")
    
    @IBOutlet weak var setupExtension: UIButton!
    
    
    
    @IBAction func settings(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Reset", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        let okButton = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (okSelected) -> Void in
            self.defaults.removeObjectForKey("code")
            self.defaults.removeObjectForKey("extensions")
            self.defaultsShared?.removeObjectForKey("barcode")
            self.defaults.setBool(true, forKey: "hasChanged")
            self.performSegueWithIdentifier("Reset", sender: nil)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (cancelSelected) -> Void in
            
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func openCardAsWebpage(sender: UIButton) {
        let usercode:String! = defaults.stringForKey("code")
        // This is the only URL that needs to be changed in order for the right url to be loaded by the Web View
        let code:String! = "http://web.shschools.org/shpid/pdfs/\(usercode).pdf"
        UIApplication.sharedApplication().openURL(NSURL(string: code)!)
    }
    
    @IBAction func SHSSchedule(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://appsto.re/us/WXoaG.i")!)
        
    }
    
    @IBAction func Schoology(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://appsto.re/us/24WIy.i")!)
        
    }
    
    @IBAction func setupAppleWatch(sender: AnyObject) {
        var tField: UITextField!
        
        func configurationTextField(textField: UITextField!){
            textField.placeholder = "S12345"
            textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            tField = textField
        }
        
        func handleCancel(alertView: UIAlertAction!){}
        
        let alert = UIAlertController(title: "Enter Student ID", message: "SHPID supports extensions. The extensions will display only the barcode, so copy the 6 digit code above your barcode, your student ID, in the main view of the app and enter it in the text field below.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            if let barcode = tField.text {
                if barcode.isEmpty {
                    self.defaultsShared?.setObject(barcode, forKey: "barcode")
                    let alert = UIAlertView()
                    alert.title = "Extensions"
                    alert.message = "Please enter a non-empty ID."
                    alert.addButtonWithTitle("Ok")
                    alert.show()
                    self.setupAppleWatch(self)
                } else {
                    self.defaultsShared?.setObject(barcode, forKey: "barcode")
                    let alert = UIAlertView()
                    alert.title = "Extensions"
                    alert.message = "You can now use extensions with SHPID."
                    alert.addButtonWithTitle("Ok")
                    alert.show()
                    self.updateUI()
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasChanged")
                }
                
            }
        }))
        self.presentViewController(alert, animated: true, completion: {
        })
    }
    
    
    override func viewDidLoad() {
        updateUI()
    }
    
    func updateUI() {
        if let barcodeCode = defaultsShared?.objectForKey("barcode") as! String? {
            setupExtension.setTitle("Change Extension: \(barcodeCode)", forState: UIControlState.Normal)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

