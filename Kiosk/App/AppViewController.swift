import UIKit

class AppViewController: UIViewController {

    let reachability = ReachabilityManager()
    var reachabilitySignal:RACSignal?

    @IBOutlet var offlineBlockingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let signal = reachabilitySignal ?? reachability.reachSignal
        offlineBlockingView.hidden = reachability.isReachable()
        RAC(offlineBlockingView, "hidden") <~ signal
    }
}
