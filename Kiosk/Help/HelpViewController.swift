import UIKit
import ORStackView
import Artsy_UILabels
import Artsy_UIButtons
import Swift_RAC_Macros
import ReactiveCocoa

class HelpViewController: UIViewController {
    var positionConstraints: [NSLayoutConstraint]?
    var dismissTapGestureRecognizer: UITapGestureRecognizer?
    
    private let stackView = ORTagBasedAutoStackView()
    
    private var buyersPremiumButton: UIButton!
    
    private let sideMargin: Float = 90.0
    private let topMargin: Float = 45.0
    private let headerMargin: Float = 25.0
    private let inbetweenMargin: Float = 10.0
    
    var showBuyersPremiumCommand = { () -> RACCommand in
        appDelegate().showBuyersPremiumCommand()
    }
    
    var registerToBidCommand = { (enabledSignal: RACSignal) -> RACCommand in
        appDelegate().registerToBidCommand(enabledSignal)
    }
    
    var requestBidderDetailsCommand = { (enabledSignal: RACSignal) -> RACCommand in
        appDelegate().requestBidderDetailsCommand(enabledSignal)
    }
    
    var showPrivacyPolicyCommand = { () -> RACCommand in
        appDelegate().showPrivacyPolicyCommand()
    }
    
    var showConditionsOfSaleCommand = { () -> RACCommand in
        appDelegate().showConditionsOfSaleCommand()
    }
    
    lazy var hasBuyersPremiumSignal: RACSignal = {
        RACObserve(appDelegate().appViewController, "sale.buyersPremium").notNil()
    }()
    
    class var width: Float {
        get {
            return 415.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure view
        view.backgroundColor = .whiteColor()
        
        addSubviews()
    }
}

private extension HelpViewController {
    
    enum SubviewTag: Int {
        case AssistanceLabel = 0
        case StuckLabel, StuckExplainLabel
        case BidLabel, BidExplainLabel
        case RegisterButton
        case BidderDetailsLabel, BidderDetailsExplainLabel, BidderDetailsButton
        case ConditionsOfSaleButton, BuyersPremiumButton, PrivacyPolicyButton
    }
    
    func addSubviews() {
        
        // Configure subviews
        let assistanceLabel = ARSerifLabel()
        assistanceLabel.font = assistanceLabel.font.fontWithSize(35)
        assistanceLabel.text = "Assistance"
        assistanceLabel.tag = SubviewTag.AssistanceLabel.rawValue
        
        let stuckLabel = titleLabel(.StuckLabel, title: "Stuck in the process?")
        
        let stuckExplainLabel = wrappingSerifLabel(.StuckExplainLabel, text: "Find the nearest Artsy representative and they will assist you.")
        
        let bidLabel = titleLabel(.BidLabel, title: "How do I place a bid?")
        
        let bidExplainLabel = wrappingSerifLabel(.BidExplainLabel, text: "Enter the amount you would like to bid. You will confirm this bid in the next step. Enter your mobile number or bidder number and PIN that you received when you registered.")
        bidExplainLabel.makeSubstringsBold(["mobile number", "bidder number", "PIN"])
        
        let registerButton = blackButton(.RegisterButton, title: "Register")
        registerButton.rac_command = registerToBidCommand(connectedToInternetOrStubbingSignal())
        
        let bidderDetailsLabel = titleLabel(.BidderDetailsLabel, title: "What Are Bidder Details?")
        
        let bidderDetailsExplainLabel = wrappingSerifLabel(.BidderDetailsExplainLabel, text: "The bidder number is how you can identify yourself to bid and see your place in bid history. The PIN is a four digit number that authenticates your bid.")
        bidderDetailsExplainLabel.makeSubstringsBold(["bidder number", "PIN"])
        
        let sendDetailsButton = blackButton(.BidderDetailsButton, title: "Send me my details")
        sendDetailsButton.rac_command = requestBidderDetailsCommand(connectedToInternetOrStubbingSignal())
        
        let conditionsButton = serifButton(.ConditionsOfSaleButton, title: "Conditions of Sale")
        conditionsButton.rac_command = showConditionsOfSaleCommand()
        
        buyersPremiumButton = serifButton(.BuyersPremiumButton, title: "Buyers Premium")
        buyersPremiumButton.rac_command = showBuyersPremiumCommand()
        
        let privacyButton = serifButton(.PrivacyPolicyButton, title: "Privacy Policy")
        privacyButton.rac_command = showPrivacyPolicyCommand()
        
        // Add subviews
        view.addSubview(stackView)
        stackView.alignTop("0", leading: "0", bottom: nil, trailing: "0", toView: view)
        stackView.addSubview(assistanceLabel, withTopMargin: "\(topMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(stuckLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(stuckExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(registerButton, withTopMargin: "20", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidderDetailsLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidderDetailsExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(sendDetailsButton, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(conditionsButton, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(privacyButton, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(self.sideMargin)")
        
        hasBuyersPremiumSignal.subscribeNext { [weak self] in
            let hasBuyersPremium = $0 as! Bool
            if hasBuyersPremium {
                self?.stackView.addSubview(self!.buyersPremiumButton, withTopMargin: "\(self!.inbetweenMargin)", sideMargin: "\(self!.sideMargin)")
            } else {
                self?.stackView.removeSubview(self!.buyersPremiumButton)
            }
        }
    }
    
    func blackButton(tag: SubviewTag, title: String) -> ARBlackFlatButton {
        let button = ARBlackFlatButton()
        button.setTitle(title, forState: .Normal)
        button.tag = tag.rawValue
        
        return button
    }
    
    func serifButton(tag: SubviewTag, title: String) -> ARUnderlineButton {
        let button = ARUnderlineButton()
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(.artsyHeavyGrey(), forState: .Normal)
        button.titleLabel?.font = UIFont.serifFontWithSize(18)
        button.contentHorizontalAlignment = .Left
        button.tag = tag.rawValue
        
        return button
    }
    
    func wrappingSerifLabel(tag: SubviewTag, text: String) -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.fontWithSize(18)
        label.lineBreakMode = .ByWordWrapping
        label.preferredMaxLayoutWidth = CGFloat(HelpViewController.width - sideMargin)
        label.tag = tag.rawValue
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        label.attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
        
        return label
    }
    
    func titleLabel(tag: SubviewTag, title: String) -> ARSerifLabel {
        let label = ARSerifLabel()
        label.font = label.font.fontWithSize(24)
        label.text = title
        label.tag = tag.rawValue
        return label
    }
}
