import UIKit

class RegisterFlowView: ORStackView {

    var highlightedIndex = 0

    var details:BidDetails? {
        didSet {
            self.setup()
        }
    }

    var titles = ["Mobile", "Email", "Credit Card", "Postal/Zip"]
    var keypaths = ["phoneNumber", "email", "creditCardToken", "zipCode"]

    func setup() {
        let user = details!.newUser
        let titleLabels = titles.map({ self.createTitleViewWithTitle($0) })
        titleLabels[highlightedIndex].textColor = UIColor.artsyPurple()

        for i in 0 ..< countElements(titles) {
            let title = titleLabels[i]
            let info = createInfoLabel()

            self.addSubview(title, topMargin: "10", sideMargin: "0")

            if user.valueForKey(keypaths[i]) != nil {
                self.addSubview(info, topMargin: "10", sideMargin: "0")
                RAC(info, "text") <~ RACObserve(user, keypaths[i])
            }
        }

        let spacer = UIView(frame: bounds)
        spacer.setContentHuggingPriority(12, forAxis: UILayoutConstraintAxis.Horizontal)
        self.addSubview(spacer, topMargin: "0", sideMargin: "0")
    }

    func createTitleViewWithTitle(title: String) -> UILabel {
        let label = UILabel(frame:self.bounds)
        label.font = UIFont.sansSerifFontWithSize(12)
        label.text = title.uppercaseString
        return label
    }

    func createInfoLabel() -> UILabel {
        let label = UILabel(frame:self.bounds)
        label.font = UIFont.serifFontWithSize(12)
        return label
    }

}
