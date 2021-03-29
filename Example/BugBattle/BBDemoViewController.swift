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
        BBSessionManager.sharedManager.request("https://httpbin.org/get").response { response in
            debugPrint(response)
        }
    }
    
}
