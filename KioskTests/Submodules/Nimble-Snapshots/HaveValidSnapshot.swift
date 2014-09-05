//
//  HaveValidSnapshot.swift
//  Bootstrap
//
//  Created by Ash Furrow on 2014-08-07.
//  Copyright (c) 2014 Artsy. All rights reserved.
//

import Foundation
import UIKit
import Nimble
import QuartzCore

@objc protocol Snapshotable {
    var snapshotObject: UIView? { get }
}

extension UIViewController : Snapshotable {
    var snapshotObject: UIView? {
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
        return view
    }
}

extension UIView : Snapshotable {
    var snapshotObject: UIView? {
        return self
    }
}

@objc class FBSnapshotTest {
    var referenceImagesDirectory: String?
    class var sharedInstance : FBSnapshotTest {
        struct Instance {
            static let instance: FBSnapshotTest = FBSnapshotTest()
        }
        return Instance.instance
    }
    
    class func setReferenceImagesDirectory(directory: String?) {
        sharedInstance.referenceImagesDirectory = directory
    }
    
    class func compareSnapshot(instance: Snapshotable, snapshot: String, testCase: AnyObject, record: Bool, referenceDirectory: String) -> Bool {
        var snapshotController: FBSnapshotTestController = FBSnapshotTestController(testClass: testCase.dynamicType)
        snapshotController.recordMode = record
        snapshotController.referenceImagesDirectory = referenceDirectory
        
        assert(snapshotController.referenceImagesDirectory != nil, "Missing value for referenceImagesDirectory - Call FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)")
        
        return snapshotController.compareSnapshotOfView(instance.snapshotObject, selector: Selector(snapshot), identifier: nil, error: nil)
    }
}

func _getDefaultReferenceDirectory(sourceFileName: String) -> String {
    if let globalReference = FBSnapshotTest.sharedInstance.referenceImagesDirectory {
        return globalReference
    }
    
    // Search the test file's path to find the first folder with the substring "tests"
    // then append "/ReferenceImages" and use that
    
    var result: NSString?
    
    let pathComponents: NSArray = sourceFileName.pathComponents
    for folder in pathComponents {
        let range = (folder.lowercaseString as NSString).rangeOfString("tests")
        
        if range.location != Foundation.NSNotFound {
            let currentIndex = pathComponents.indexOfObject(folder)
            let folderPathComponents: NSArray = pathComponents.subarrayWithRange(NSMakeRange(0, currentIndex))
            let folderPath = folderPathComponents.componentsJoinedByString("/")
            result = folderPath + "/ReferenceImages"
        }
    }
    
    assert(result != nil, "Could not infer reference image folder – You should provide a reference dir using FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)")
    
    return result!
}

func _sanitizedTestPath(sourceLocation: String) -> String {
    let filename = sourceLocation.pathComponents.last!
    let characterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    let components: NSArray = filename.componentsSeparatedByCharactersInSet(characterSet.invertedSet)
    return components.componentsJoinedByString("_")
}

func _clearFailureMessage(failureMessage: FailureMessage) {
    failureMessage.actualValue = ""
    failureMessage.expected = ""
    failureMessage.postfixMessage = ""
    failureMessage.to = ""
}

func _performSnapshotTest(name: String, actualExpression: Expression<Snapshotable>, failureMessage: FailureMessage) -> Bool {
    let instance = actualExpression.evaluate()
    let testFileLocation = actualExpression.location.file
    let referenceImageDirectory = _getDefaultReferenceDirectory(testFileLocation)
    
    let result = FBSnapshotTest.compareSnapshot(instance, snapshot: name, testCase: instance, record: false, referenceDirectory: referenceImageDirectory)
    
    if !result {
        _clearFailureMessage(failureMessage)
        failureMessage.actualValue = "expected a matching snapshot in \(name)"
    }
    
    return result
    
}

func _recordSnapshot(name: String, actualExpression: Expression<Snapshotable>, failureMessage: FailureMessage) -> Bool {
    let instance = actualExpression.evaluate()
    let testFileLocation = actualExpression.location.file
    let referenceImageDirectory = _getDefaultReferenceDirectory(testFileLocation)
    let name = _sanitizedTestPath(testFileLocation)
    
    _clearFailureMessage(failureMessage)
    
    if FBSnapshotTest.compareSnapshot(instance, snapshot: name, testCase: instance, record: true, referenceDirectory: referenceImageDirectory) {
        failureMessage.actualValue = "snapshot \(name) successfully recorded, replace recordSnapshot with a check"
    } else {
        failureMessage.actualValue = "expected to record a snapshot in \(name)"
    }
    
    return false
}

func haveValidSnapshot() -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        let testFileLocation = actualExpression.location.file
        let name = _sanitizedTestPath(testFileLocation)
        
        return _performSnapshotTest(name, actualExpression, failureMessage)
    }
}

func haveValidSnapshot(named name: String) -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        let testFileLocation = actualExpression.location.file

        return _performSnapshotTest(name, actualExpression, failureMessage)
    }
}

func recordSnapshot() -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        let testFileLocation = actualExpression.location.file
        let name = _sanitizedTestPath(testFileLocation)
        
        return _recordSnapshot(name, actualExpression, failureMessage)
    }
}

func recordSnapshot(named name: String) -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        return _recordSnapshot(name, actualExpression, failureMessage)
    }
}
