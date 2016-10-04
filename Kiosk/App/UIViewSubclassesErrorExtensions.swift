import UIKit

extension Button {

    func flashError(_ message:String) {
        let originalTitle = self.title(for: UIControlState())

        setTitleColor(.white(), for: .disabled)
        setBackgroundColor(.artsyRed(), for: .disabled, animated: true)
        setBorderColor(.artsyRed(), for: .disabled, animated: true)

        setTitle(message.uppercased(), for: .disabled)

        delayToMainThread(2) {
            self.setTitleColor(.artsyMediumGrey(), for: .disabled)
            self.setBackgroundColor(.white(), for: .disabled, animated: true)
            self.setTitle(originalTitle, for: .disabled)
            self.setBorderColor(.artsyMediumGrey(), for: .disabled, animated: true)
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
