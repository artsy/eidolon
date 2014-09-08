//
//  FulfillmentContainerViewController.swift
//  Kiosk
//
//  Created by Orta on 9/8/14.
//  Copyright (c) 2014 Artsy. All rights reserved.
//

import UIKit

public class FulfillmentContainerViewController: UIViewController {
    public var allowAnimations:Bool = true;

    public class func instantiateFromStoryboard() -> FulfillmentContainerViewController {
        return  UIStoryboard(name: "Fulfillment", bundle: nil)
            .instantiateViewControllerWithIdentifier("FulfillmentContainerViewController") as FulfillmentContainerViewController
    }
    
    @IBAction public func closeModalTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(allowAnimations, completion: nil)
    }
}
