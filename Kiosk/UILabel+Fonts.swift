import UIKit

extension UILabel {
    func makeSubstringsBold(text: [String]) {
        text.forEach { self.makeSubstringBold($0) }
    }

    func makeSubstringBold(text: String) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString

        let range: NSRange! = (self.text ?? NSString()).rangeOfString(text)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifSemiBoldFontWithSize(self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func makeSubstringsItalic(text: [String]) {
        text.forEach { self.makeSubstringItalic($0) }
    }

    func makeSubstringItalic(text: String) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString

        let range: NSRange! = (self.text ?? NSString()).rangeOfString(text)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifItalicFontWithSize(self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func setLineHeight(lineHeight: Int) {
        let displayText = text ?? ""
        let attributedString = NSMutableAttributedString(string: displayText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineHeight)
        paragraphStyle.alignment = textAlignment
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, displayText.characters.count))

        attributedText = attributedString
    }

    func makeTransparent() {
        opaque = false
        backgroundColor = .clearColor()
    }
}
