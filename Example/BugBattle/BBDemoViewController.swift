//
//  BBDemoViewController.swift
//  BugBattle_Example
//
//  Created by Lukas Boehler on 29.03.21.
//  Copyright © 2021 Lukas Böhler. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import BugBattle

class DemoViewController: UIViewController {
    
    override func viewDidLoad() {
        BugBattle.logEvent("User signed in", withData: [
            "userId": "1242",
            "name": "Isabella",
            "skillLevel": "🤩"
        ])
        
        for _ in 1 ... 15 {
            BBSessionManager.sharedManager.request("https://httpbin.org/get").response { response in
                debugPrint(response)
                
                
                BugBattle.sendSilentBugReport(with: "hello@email.some", andDescription: "Error on startup", andPriority: MEDIUM)
            }
        }
    }
    
}
