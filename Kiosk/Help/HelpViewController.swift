import UIKit

class HelpViewController: UIViewController {
    var positionConstraints: NSArray?
    
    private let stackView = ORStackView()
    private let reachabilityManager = ReachabilityManager()
    
    private let sideMargin: Float = 90.0
    private let topMargin: Float = 45.0
    private let headerMargin: Float = 30.0
    private let inbetweenMargin: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure view
        view.backgroundColor = UIColor.whiteColor()
        
        // Configure subviews
        let assistanceLabel = ARSerifLabel()
        assistanceLabel.font = assistanceLabel.font.fontWithSize(35)
        assistanceLabel.text = "Assistance"
        
        let stuckLabel = titleLabel()
        stuckLabel.text = "Stuck in the process?"
        
        let stuckExplainLabel = wrappingSerifLabel()
        stuckExplainLabel.text = "Find the nearest Artsy representative and they will assist you with anything you may need help with."
        
        let bidLabel = titleLabel()
        bidLabel.text = "How do I place a bid?"
        
        let bidExplainLabel = wrappingSerifLabel()
        bidExplainLabel.text = "Enter the amount you would like to bid. You will confirm this bid in the next step.\n\nEnter your mobile number or bidder number and PIN that you received when you registered."
        bidExplainLabel.makeSubstringsBold(["mobile number", "bidder number", "PIN"])

        let registerButton = ARBlackFlatButton()
        registerButton.setTitle("Register", forState: .Normal)
        RAC(registerButton, "enabled") <~ reachabilityManager.reachSignal

        registerButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) -> Void in
            (UIApplication.sharedApplication().delegate as? AppDelegate)?.showRegistration()
            return
        }
        
        let txtLabel = wrappingSerifLabel()
        txtLabel.text = "We will send you a text message and email to update you on the status of your bid."
        
        let bidderDetailsLabel = titleLabel()
        bidderDetailsLabel.text = "What Are Bidder Details?"
        
        let bidderDetailsExplainLabel = wrappingSerifLabel()
        bidderDetailsExplainLabel.text = "The bidder number is how you can identify yourself to bid and see your place in bid history. The PIN is a four digit number that authenticates your bid."
        bidderDetailsExplainLabel.makeSubstringsBold(["bidder number", "PIN"])
        
        let questionsLabel = titleLabel()
        questionsLabel.text = "Questions About Artsy Auctions?"
        
        let questionsExplainView: UIView = {
            let view = UIView()
            
            let conditionsLabel = ARSerifLabel()
            conditionsLabel.font = conditionsLabel.font.fontWithSize(18)
            conditionsLabel.text = "View our "
            
            let conditionsButton = ARUnderlineButton()
            conditionsButton.setTitle("Conditions of Sale".uppercaseString, forState: .Normal)
            conditionsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            conditionsButton.titleLabel?.font = UIFont.sansSerifFontWithSize(15)
            
            conditionsButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (_) -> Void in
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.showConditionsOfSale()
                return
            })
            
            let privacyLabel = ARSerifLabel()
            privacyLabel.font = conditionsLabel.font.fontWithSize(18)
            privacyLabel.text = "View our "
            
            let privacyButton = ARUnderlineButton()
            privacyButton.setTitle("Privacy Policy".uppercaseString, forState: .Normal)
            privacyButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            privacyButton.titleLabel?.font = UIFont.sansSerifFontWithSize(15)
            
            privacyButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (_) -> Void in
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.showPrivacyPolicy()
                return
            })
            
            view.addSubview(conditionsLabel)
            view.addSubview(conditionsButton)
            view.addSubview(privacyLabel)
            view.addSubview(privacyButton)
            
            conditionsLabel.alignTop("0", leading: "0", toView: view)
            conditionsLabel.alignBaselineWithView(conditionsButton, predicate: nil)
            conditionsButton.alignAttribute(.Left, toAttribute: .Right, ofView: conditionsLabel, predicate: "0")
            
            privacyLabel.alignAttribute(.Left, toAttribute: .Left, ofView: conditionsLabel, predicate: "0")
            privacyLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: conditionsLabel, predicate: "10")
            privacyLabel.alignAttribute(.Bottom, toAttribute: .Bottom, ofView: view, predicate: "-20")
            privacyLabel.alignBaselineWithView(privacyButton, predicate: nil)
            privacyButton.alignAttribute(.Left, toAttribute: .Right, ofView: privacyLabel, predicate: "0")
            
            return view
        }()
        
        // Add subviews
        view.addSubview(stackView)
        stackView.alignTop("0", leading: "0", bottom: nil, trailing: "0", toView: view)
        stackView.addSubview(assistanceLabel, withTopMargin: "\(topMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(stuckLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(stuckExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(registerButton, withTopMargin: "20", sideMargin: "\(sideMargin)")
        stackView.addSubview(txtLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidderDetailsLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidderDetailsExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(questionsLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(questionsExplainView, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(self.sideMargin)")
    }

    private func wrappingSerifLabel() -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.fontWithSize(18)
        label.lineBreakMode = .ByWordWrapping
        label.preferredMaxLayoutWidth = CGFloat(HelpViewController.width - sideMargin)
        return label
    }

    private func titleLabel() -> ARSansSerifLabel {
        let label = ARSansSerifLabel()
        label.font = UIFont.sansSerifFontWithSize(14)
        return label
    }
}

extension HelpViewController {
    class var width: Float {
        get {
            return 415.0
        }
    }
}