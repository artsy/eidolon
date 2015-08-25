import UIKit

extension Button {

    func flashError(message:String) {
        let originalTitle = self.titleForState(.Normal)

        setTitleColor(UIColor.whiteColor(), forState: .Disabled)
        setBackgroundColor(UIColor.artsyRed(), forState: .Disabled, animated: true)
        setBorderColor(UIColor.artsyRed(), forState: .Disabled, animated: true)

        setTitle(message.uppercaseString, forState: .Disabled)

        delayToMainThread(2) {
            self.setTitleColor(UIColor.artsyMediumGrey(), forState: .Disabled)
            self.setBackgroundColor(UIColor.whiteColor(), forState: .Disabled, animated: true)
            self.setTitle(originalTitle, forState: .Disabled)
            self.setBorderColor(UIColor.artsyMediumGrey(), forState: .Disabled, animated: true)
        }
    }
}

extension TextField {

    func flashForError() {
        self.setBorderColor(UIColor.artsyRed())
        delayToMainThread(2) {
            self.setBorderColor(UIColor.artsyPurple())
        }
    }
}