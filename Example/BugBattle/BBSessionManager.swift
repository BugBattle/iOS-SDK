//
//  BBSessionManager.swift
//  BugBattle_Example
//
//  Created by Lukas Boehler on 29.03.21.
//  Copyright © 2021 Lukas Böhler. All rights reserved.
//

import Foundation
import Alamofire
import BugBattle

class BBSessionManager: Alamofire.Session {
    static let sharedManager: BBSessionManager = {
        let configuration = URLSessionConfiguration.default
        BugBattle.startNetworkRecording(for:  configuration)
        let manager = BBSessionManager(configuration: configuration)
        return manager
    }()
}
