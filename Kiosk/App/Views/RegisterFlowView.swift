import UIKit
import ORStackView
import RxSwift

class RegisterFlowView: ORStackView {

    let highlightedIndex = Variable(0)

    lazy var appSetup: AppSetup = .sharedState

    var details: BidDetails? {
        didSet {
            update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .whiteColor()
        bottomMarginHeight = CGFloat(NSNotFound)
        updateConstraints()
    }

    private struct SubViewParams {
        let title: String
        let getters: Array<NewUser -> String?>
    }

    private lazy var subViewParams: Array<SubViewParams> = {
        return [
            [SubViewParams(title: "Mobile", getters: [{ $0.phoneNumber.value }])],
            [SubViewParams(title: "Email", getters: [{ $0.email.value }])],
            [SubViewParams(title: "Postal/Zip", getters: [{ $0.zipCode.value }])].filter { _ in self.appSetup.needsZipCode },
            [SubViewParams(title: "Credit Card", getters: [{ $0.creditCardName.value }, { $0.creditCardType.value }])]
        ].flatMap {$0}
    }()

    func update() {
        let user = details!.newUser

        removeAllSubviews()
        for (i, subViewParam) in subViewParams.enumerate() {
            let itemView = ItemView(frame: bounds)
            itemView.createTitleViewWithTitle(subViewParam.title)

            addSubview(itemView, withTopMargin: "10", sideMargin: "0")

            if let value = (subViewParam.getters.flatMap { $0(user) }.first) {
                itemView.createInfoLabel(value)

                let button = itemView.createJumpToButtonAtIndex(i)
                button.addTarget(self, action: #selector(pressed(_:)), forControlEvents: .TouchUpInside)

                itemView.constrainHeight("44")
            } else {
                itemView.constrainHeight("20")
            }

            if i == highlightedIndex.value {
                itemView.highlight()
            }
        }

        let spacer = UIView(frame: bounds)
        spacer.setContentHuggingPriority(12, forAxis: .Horizontal)
        addSubview(spacer, withTopMargin: "0", sideMargin: "0")

        bottomMarginHeight = 0
    }

    func pressed(sender: UIButton!) {
        highlightedIndex.value = sender.tag
    }

    class ItemView : UIView {

        var titleLabel: UILabel?

        func highlight() {
            titleLabel?.textColor = .artsyPurple()
        }

        func createTitleViewWithTitle(title: String)  {
            let label = UILabel(frame: bounds)
            label.font = UIFont.sansSerifFontWithSize(16)
            label.text = title.uppercaseString
            titleLabel = label

            addSubview(label)
            label.constrainWidthToView(self, predicate: "0")
            label.alignLeadingEdgeWithView(self, predicate: "0")
            label.alignTopEdgeWithView(self, predicate: "0")
        }

        func createInfoLabel(info: String) {
            let label = UILabel(frame: bounds)
            label.font = UIFont.serifFontWithSize(16)
            label.text = info

            addSubview(label)
            label.constrainWidthToView(self, predicate: "-52")
            label.alignLeadingEdgeWithView(self, predicate: "0")
            label.constrainTopSpaceToView(titleLabel!, predicate: "8")
        }

        func createJumpToButtonAtIndex(index: NSInteger) -> UIButton {
            let button = UIButton(type: .Custom)
            button.tag = index
            button.setImage(UIImage(named: "edit_button"), forState: .Normal)
            button.userInteractionEnabled = true
            button.enabled = true

            addSubview(button)
            button.alignTopEdgeWithView(self, predicate: "0")
            button.alignTrailingEdgeWithView(self, predicate: "0")
            button.constrainWidth("36")
            button.constrainHeight("36")
            
            return button

        }
    }
}
