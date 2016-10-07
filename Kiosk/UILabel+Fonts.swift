import UIKit

extension UILabel {
    func makeSubstringsBold(text: [String]) {
        text.forEach { self.makeSubstringBold(text: $0) }
    }

    func makeSubstringBold(text: String) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString
        let nsString = text as NSString

        // From http://stackoverflow.com/a/27041376/516359
        nsString.enumerateSubstrings(in: NSMakeRange(0, nsString.length), options: []) { (_, range, _, _) in
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifSemiBoldFont(withSize: self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func makeSubstringsItalic(text: [String]) {
        text.forEach { self.makeSubstringItalic(text: $0) }
    }

    func makeSubstringItalic(text: String) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString
        let nsString = text as NSString

        // From http://stackoverflow.com/a/27041376/516359
        nsString.enumerateSubstrings(in: NSMakeRange(0, nsString.length), options: []) { (_, range, _, _) in
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifItalicFont(withSize: self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func setLineHeight(_ lineHeight: Int) {
        let displayText = text ?? ""
        let attributedString = NSMutableAttributedString(string: displayText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineHeight)
        paragraphStyle.alignment = textAlignment
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, displayText.characters.count))

        attributedText = attributedString
    }

    func makeTransparent() {
        isOpaque = false
        backgroundColor = .clear
    }
}
