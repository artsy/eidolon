//
//  main.swift
//  Kiosk
//
//  Created by Scott Hoyt on 9/29/16.
//  Copyright © 2016 Artsy. All rights reserved.
//

import Foundation
import UIKit

// Determine if we are testing by checking for XCTest injected bundle
func isRunningTests() -> Bool {
    let environment = NSProcessInfo.processInfo().environment
    if let injectBundle = environment["XCInjectBundle"] {
        return injectBundle.pathExtension == "xctest"
    }
    return false
}

let appDelegateClass: AnyClass = isRunningTests() ? TestAppDelegate.self : AppDelegate.self

UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(UIApplication), NSStringFromClass(appDelegateClass))
