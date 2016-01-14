//
//  CodereqViewController.swift
//  SHP ID APP
//
//  Created by Dylan Modesitt on 4/5/15.
//  Copyright (c) 2015 Dylan Modesitt. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import CoreData

class RequestViewController: UIViewController {
    
    @IBOutlet weak var codereqwebview: UIWebView!
    
    // will load the website for the code request section!
    
    override func viewDidAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false {
            let alertController = UIAlertController(title: "ERROR", message: "Please ensure you have an internet connection to request your SHPID code. You may need to leave the \"Guest\" Wi-Fi network on the SHS campus.", preferredStyle: .Alert)
             let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in self.performSegueWithIdentifier("Back", sender: nil)
            
             }
             alertController.addAction(OKAction)
        
             self.presentViewController(alertController, animated: true) {
             }
             return
        } else {
            
        }
    }
                
            
    override func viewDidLoad() {
        // This url needs to be the URL of the code request site
        let url = NSURL (string: "http://web.shschools.org/shpid/recover");
        let requestObj = NSURLRequest(URL: url!);
        self.codereqwebview.loadRequest(requestObj);
        self.view.addSubview(self.codereqwebview)
        }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    
}

