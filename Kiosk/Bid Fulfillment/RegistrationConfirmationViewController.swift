import Foundation
import UIKit
import RxSwift

let targetConditionsOfSaleText = "Conditions of Sale"

class RegistrationConfirmationViewController: UIViewController {
    @IBOutlet weak var confirmationLabel: ARSerifLabel!
    @IBOutlet weak var conditionsOfSaleCheckbox: UIButton!

    fileprivate let _conditionsOfSaleChecked: Variable<Bool> = Variable(false)
    var conditionsOfSaleChecked: Observable<Bool> {
        return _conditionsOfSaleChecked.asObservable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmationLabel.makeSubstringUnderlined(targetConditionsOfSaleText)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationConfirmationViewController.userDidTapConditionsOfSale(_:)))
        confirmationLabel.addGestureRecognizer(gestureRecognizer)

        // Not sure why this isn't taking the Interface Builder setting, so we're doing it in code, too.
        conditionsOfSaleCheckbox.contentHorizontalAlignment = .left
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
        } else {
            // We're going to assume that they tapped on "I agree to the" and toggle the checkmark
            toggleConditionsOfSaleChecked()
        }
    }

    @IBAction func conditionsOfSaleCheckmarkTapped(_ sender: Any) {
        toggleConditionsOfSaleChecked()
    }

    func toggleConditionsOfSaleChecked() {
        _conditionsOfSaleChecked.value = !_conditionsOfSaleChecked.value

        if _conditionsOfSaleChecked.value {
            conditionsOfSaleCheckbox.setImage(UIImage.init(named: "checkmark_checked"), for: .normal)
        } else {
            conditionsOfSaleCheckbox.setImage(UIImage.init(named: "checkmark_unchecked"), for: .normal)
        }
    }
}
