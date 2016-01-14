//
//  TodayViewController.swift
//  SHPID
//
//  Created by Dylan Modesitt on 8/31/15.
//  Copyright (c) 2015 Dylan Modesitt. All rights reserved.
//

import UIKit
import CoreMedia
import NotificationCenter
import AVFoundation


class TodayViewController: UIViewController, NCWidgetProviding {
    
    var defaultsShared = NSUserDefaults(suiteName: "group.org.shschools.shpidcard.shared")
    let defaults = NSUserDefaults.standardUserDefaults()

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var barcode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let string = defaultsShared!.objectForKey("barcode") as? String
        print("Shared String \(string)")
        if let barcodeString = defaultsShared!.objectForKey("barcode") as? String {
            print("Shared String" + barcodeString)
            if let barcodeContent = RSUnifiedCodeGenerator.shared.generateCode(barcodeString, machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code) {
                barcode.image = barcodeContent
                label.text = "ID#: \(barcodeString)"
            } else {
                label.text = "Please setup extensions in the settings of SHPID."
                barcode.hidden = true
                barcode.removeFromSuperview()  // this removes it from your view hierarchy
                barcode = nil;
                self.preferredContentSize = CGSizeMake(50, 100);
            }
        } else {
            barcode.hidden = true
            label.text = "Please setup extensions in the settings of SHPID."
            barcode.removeFromSuperview()  // this removes it from your view hierarchy
            barcode = nil;
            self.preferredContentSize = CGSizeMake(50, 100);
        }

    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
