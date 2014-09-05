import UIKit

public class ListingsViewController: UIViewController {
    public var allowAnimations:Bool = true;
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction public func showModal(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Fulfillment", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as UIViewController
        self.presentViewController(controller, animated: allowAnimations, completion: nil)
    }

}

