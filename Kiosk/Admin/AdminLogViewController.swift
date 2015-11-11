import UIKit

class AdminLogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = try? NSString(contentsOfURL: logPath(), encoding: NSASCIIStringEncoding) as String
    }

    @IBOutlet weak var textView: UITextView!
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func logPath() -> NSURL {
        let docs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        return docs.URLByAppendingPathComponent("logger.txt")
    }

    @IBAction func scrollTapped(sender: AnyObject) {
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count - 1, 1))
    }
}
