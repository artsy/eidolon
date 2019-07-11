import Foundation
import UIKit

class RegistrationConfirmationViewController: UIViewController {
    @IBOutlet weak var confirmationLabel: ARSerifLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmationLabel.makeSubstringUnderlined("Conditions of Sale")

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationConfirmationViewController.userDidTapConditionsOfSale(_:)))
        confirmationLabel.addGestureRecognizer(gestureRecognizer)
    }

    @objc func userDidTapConditionsOfSale(_ recognizer: UITapGestureRecognizer) {
        // TODO: Need to check that the user tapped just "Conditions of Sale"
        // Look here: https://samwize.com/2016/03/04/how-to-create-multiple-tappable-links-in-a-uilabel/
        // Also here: https://stackoverflow.com/questions/28053334/how-to-underline-a-uilabel-in-swift
        print("I've been tapped!")
    }
}
