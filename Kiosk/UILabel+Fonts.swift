import UIKit

public extension UILabel {
    public func makeSubstringsBold(text: [String]) {
        text.map {
            self.makeSubstringBold($0)
        }
    }

    public func makeSubstringBold(text: String) {
        let attributedText = self.attributedText.mutableCopy() as! NSMutableAttributedString

        let range: NSRange! = (self.text ?? NSString()).rangeOfString(text)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifSemiBoldFontWithSize(self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    public func makeSubstringsItalic(text: [String]) {
        text.map {
            self.makeSubstringItalic($0)
        }
    }

    public func makeSubstringItalic(text: String) {
        let attributedText = self.attributedText.mutableCopy() as! NSMutableAttributedString

        let range: NSRange! = (self.text ?? NSString()).rangeOfString(text)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifItalicFontWithSize(self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    public func setLineHeight(lineHeight: Int) {
        let displayText = text ?? ""
        let attributedString = NSMutableAttributedString(string: displayText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineHeight)
        paragraphStyle.alignment = textAlignment
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, count(displayText)))

        attributedText = attributedString
    }

    public func makeTransparent() {
        opaque = false
        backgroundColor = .clearColor()
    }
}
