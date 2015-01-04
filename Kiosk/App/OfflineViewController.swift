import UIKit
import Artsy_UIFonts

class OfflineViewController: UIViewController {
    @IBOutlet var offlineLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        offlineLabel.font = UIFont.serifFontWithSize(49)
        subtitleLabel.font = UIFont.serifItalicFontWithSize(32)
    }
}