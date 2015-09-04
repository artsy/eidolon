import UIKit

extension Button {

    func flashError(message:String) {
        let originalTitle = self.titleForState(.Normal)

        setTitleColor(.whiteColor(), forState: .Disabled)
        setBackgroundColor(.artsyRed(), forState: .Disabled, animated: true)
        setBorderColor(.artsyRed(), forState: .Disabled, animated: true)

        setTitle(message.uppercaseString, forState: .Disabled)

        delayToMainThread(2) {
            self.setTitleColor(.artsyMediumGrey(), forState: .Disabled)
            self.setBackgroundColor(.whiteColor(), forState: .Disabled, animated: true)
            self.setTitle(originalTitle, forState: .Disabled)
            self.setBorderColor(.artsyMediumGrey(), forState: .Disabled, animated: true)
        }
    }
}

extension TextField {

    func flashForError() {
        self.setBorderColor(.artsyRed())
        delayToMainThread(2) {
            self.setBorderColor(.artsyPurple())
        }
    }
}