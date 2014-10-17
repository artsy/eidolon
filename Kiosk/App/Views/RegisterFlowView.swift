import UIKit

class RegisterFlowView: ORStackView {

    dynamic var highlightedIndex = 0
    let jumpToIndexSignal = RACSubject()

    var details:BidDetails? {
        didSet {
            self.update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.whiteColor()

        self.bottomMarginHeight = CGFloat(NSNotFound)
        self.updateConstraints()
    }
    
    var titles = ["Mobile", "Email", "Credit Card", "Postal/Zip"]
    var keypaths = ["phoneNumber", "email", "creditCardName", "zipCode"]

    func update() {
        let user = details!.newUser
        let titleLabels = titles.map(createTitleViewWithTitle)

        removeAllSubviews()
        for i in 0 ..< countElements(titles) {
            let title = titleLabels[i]
            let info = createInfoLabel()

            addSubview(title, withTopMargin: "10", sideMargin: "0")

            if user.valueForKey(keypaths[i]) != nil {
                addSubview(info, withTopMargin: "10", sideMargin: "0")
                RAC(info, "text") <~ RACObserve(user, keypaths[i])

                let jumpToButton = createJumpToButtonAtIndex(i)
                title.addSubview(jumpToButton)
                jumpToButton.alignTopEdgeWithView(title, predicate: "0")
                jumpToButton.alignTrailingEdgeWithView(title, predicate: "0")
            }
        }
        
        if highlightedIndex < countElements(titleLabels) {
            titleLabels[highlightedIndex].textColor = UIColor.artsyPurple()
        }

        let spacer = UIView(frame: bounds)
        spacer.setContentHuggingPriority(12, forAxis: UILayoutConstraintAxis.Horizontal)
        addSubview(spacer, withTopMargin: "0", sideMargin: "0")
    }

    func tappedAJumpToButton(button:UIButton) {
        jumpToIndexSignal.sendNext(button.tag)
    }

    func createTitleViewWithTitle(title: String) -> UILabel {
        let label = UILabel(frame:self.bounds)
        label.font = UIFont.sansSerifFontWithSize(16)
        label.text = title.uppercaseString
        return label
    }

    func createInfoLabel() -> UILabel {
        let label = UILabel(frame:self.bounds)
        label.font = UIFont.serifFontWithSize(16)
        return label
    }

    func createJumpToButtonAtIndex(index: NSInteger) -> UIButton {
        let button = UIButton(frame: CGRectZero)
        button.tag = index
        button.setImage(UIImage(named: "edit_button"), forState: .Normal)

        return button
    }


}
