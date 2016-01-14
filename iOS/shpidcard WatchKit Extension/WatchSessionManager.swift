//
//  WatchSessionManager.swift
//  shpidcard
//
//  Created by Dylan Modesitt on 10/12/15.
//  Copyright © 2015 Dylan Modesitt. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    private let session: WCSession = WCSession.defaultSession()
    
    func startSession() {
        session.delegate = self
        session.activateSession()
    }
}