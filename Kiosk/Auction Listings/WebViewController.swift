let modalHeight: CGFloat = 660

class WebViewController: DZNWebViewController {
    var showToolbar = true

    convenience init(url: NSURL) {
        self.init()
        self.URL = url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = view as UIWebView
        webView.scalesPageToFit = true
        
        self.navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated:false)
        navigationController?.setToolbarHidden(!showToolbar, animated:false)
    }
}

class ModalWebViewController: WebViewController {
    var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton = UIButton()
        view.addSubview(closeButton)
        closeButton.titleLabel?.font = UIFont.sansSerifFontWithSize(14)
        closeButton.setTitleColor(UIColor.artsyMediumGrey(), forState:.Normal)
        closeButton.setTitle("CLOSE", forState:.Normal)
        closeButton.constrainWidth("140", height: "72")
        closeButton.alignTop("0", leading:"0", bottom:nil, trailing:nil, toView:view)
        closeButton.addTarget(self, action:"closeTapped:", forControlEvents:.TouchUpInside)

        var height = modalHeight
        if let nav = navigationController {
            if !nav.navigationBarHidden { height -= CGRectGetHeight(nav.navigationBar.frame) }
            if !nav.toolbarHidden { height -= CGRectGetHeight(nav.toolbar.frame) }
        }
        preferredContentSize = CGSizeMake(815, height)
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.superview?.layer.cornerRadius = 0;
    }

    func closeTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion:nil)
    }
}
