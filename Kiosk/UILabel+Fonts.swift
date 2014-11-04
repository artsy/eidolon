import UIKit

extension UILabel {
    func makeSubstringsBold(text: [String]) {
        text.map {
            self.makeSubstringBold($0)
        }
    }

    func makeSubstringBold(text: String) {
        let attributedText = self.attributedText.mutableCopy() as NSMutableAttributedString

        let range: NSRange! = (self.text ?? NSString()).rangeOfString(text)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifSemiBoldFontWithSize(self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func makeSubstringsItalic(text: [String]) {
        text.map {
            self.makeSubstringItalic($0)
        }
    }

    func makeSubstringItalic(text: String) {
        let attributedText = self.attributedText.mutableCopy() as NSMutableAttributedString

        let range: NSRange! = (self.text ?? NSString()).rangeOfString(text)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifItalicFontWithSize(self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }
}