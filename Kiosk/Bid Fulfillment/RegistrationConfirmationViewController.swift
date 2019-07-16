import Foundation
import UIKit

let targetConditionsOfSaleText = "Conditions of Sale"

class RegistrationConfirmationViewController: UIViewController {
    @IBOutlet weak var confirmationLabel: ARSerifLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmationLabel.makeSubstringUnderlined(targetConditionsOfSaleText)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationConfirmationViewController.userDidTapConditionsOfSale(_:)))
        confirmationLabel.addGestureRecognizer(gestureRecognizer)
    }

    // This implementation is based on this blog post: https://samwize.com/2016/03/04/how-to-create-multiple-tappable-links-in-a-uilabel/
    @objc func userDidTapConditionsOfSale(_ recognizer: UITapGestureRecognizer) {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: confirmationLabel.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = confirmationLabel.lineBreakMode
        textContainer.maximumNumberOfLines = confirmationLabel.numberOfLines
        let labelSize = confirmationLabel.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = recognizer.location(in: confirmationLabel)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInLabel, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        let targetRange = ((confirmationLabel.text ?? "") as NSString).range(of: targetConditionsOfSaleText)
        if NSLocationInRange(indexOfCharacter, targetRange) {
            AppDelegate().showUserWebViewAtAddress(ConditionsOfSaleLink)
        }
    }
}
