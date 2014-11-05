import UIKit

class AdminLogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = NSString(contentsOfURL: logPath(), encoding: NSASCIIStringEncoding, error: nil)
    }

    @IBOutlet weak var textView: UITextView!
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func logPath() -> NSURL {
        let docs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
        return docs.URLByAppendingPathComponent("logger.txt")
    }

}
