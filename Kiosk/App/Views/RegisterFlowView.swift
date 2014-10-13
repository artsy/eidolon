import UIKit

class RegisterFlowView: ORStackView {

    dynamic var highlightedIndex = 0
    
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
    var keypaths = ["phoneNumber", "email", "creditCardToken", "zipCode"]

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
            }
        }
        
        if highlightedIndex < countElements(titleLabels) {
            titleLabels[highlightedIndex].textColor = UIColor.artsyPurple()
        }

        let spacer = UIView(frame: bounds)
        spacer.setContentHuggingPriority(12, forAxis: UILayoutConstraintAxis.Horizontal)
        addSubview(spacer, withTopMargin: "0", sideMargin: "0")
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
