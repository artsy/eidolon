import UIKit

class HelpViewController: UIViewController {
    var positionConstraints: NSArray?
    
    private let stackView = ORStackView()
    
    private let sideMargin: Float = 80.0
    private let topMargin: Float = 40.0
    private let inbetweenMargin: Float = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure view
        view.backgroundColor = UIColor.whiteColor()
        
        // Configure subviews
        let assistanceLabel = ARSerifLabel()
        assistanceLabel.font = assistanceLabel.font.fontWithSize(40)
        assistanceLabel.text = "Assistance"
        
        let stuckLabel = titleLabel()
        stuckLabel.text = "Stuck in the process?"
        
        let stuckExplainLabel = wrappingSerifLabel()
        stuckExplainLabel.text = "Find the nearest Artsy representative and they will assist you with anything you may need help with."
        
        let bidLabel = titleLabel()
        bidLabel.text = "How do I place a bid?"
        
        let bidExplainLabel = wrappingSerifLabel()
        bidExplainLabel.text = "Enter the amount you would like to bid. You will confirm this bid in the next step.\n\nEnter your mobile number or bidder number and PIN that you received when you registered."
        
        let bidDetailsButton = ARBlackFlatButton()
        bidDetailsButton.setTitle("Register", forState: .Normal)
        bidDetailsButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) -> Void in
            (UIApplication.sharedApplication().delegate as? AppDelegate)?.showRegistration()
            return
        }
        
        let txtLabel = wrappingSerifLabel()
        txtLabel.text = "We will send you a text message and email to update you on the status of your bid."
        
        let questionsLabel = titleLabel()
        questionsLabel.text = "Questions About Artsy Auctions?"
        
        let questionsExplainView: UIView = {
            let view = UIView()
            
            let prefixLabel = ARSerifLabel()
            prefixLabel.text = "View our "
            
            let button = ARUnderlineButton()
            button.setTitle("Conditions of Sale".uppercaseString, forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.titleLabel?.font = UIFont.sansSerifFontWithSize(15)
            
            button.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (_) -> Void in
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.showConditionsOfSale()
                return
            })
            
            view.addSubview(prefixLabel)
            view.addSubview(button)
            
            prefixLabel.alignTop("0", leading: "0", toView: view)
            prefixLabel.alignBaselineWithView(button, predicate: nil)
            prefixLabel.alignLeading("0", trailing: nil, toView: view)
            button.alignAttribute(.Left, toAttribute: .Right, ofView: prefixLabel, predicate: "0")
            
            return view
        }()
        
        // Add subviews
        view.addSubview(stackView)
        stackView.alignTop("0", leading: "0", bottom: nil, trailing: "0", toView: view)
        self.stackView.addSubview(assistanceLabel, withTopMargin: "\(self.topMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(stuckLabel, withTopMargin: "\(self.topMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(stuckExplainLabel, withTopMargin: "\(self.inbetweenMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(bidLabel, withTopMargin: "\(self.topMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(bidExplainLabel, withTopMargin: "\(self.inbetweenMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(bidDetailsButton, withTopMargin: "\(self.inbetweenMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(txtLabel, withTopMargin: "\(self.inbetweenMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(questionsLabel, withTopMargin: "\(self.topMargin)", sideMargin: "\(self.sideMargin)")
        self.stackView.addSubview(questionsExplainView, withTopMargin: "\(self.inbetweenMargin)", sideMargin: "\(self.sideMargin)")
    }

    private func wrappingSerifLabel() -> UILabel {
        let label = ARSerifLabel()
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
            return 400.0
        }
    }
}