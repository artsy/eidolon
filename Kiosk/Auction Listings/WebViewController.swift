class WebViewController: DZNWebViewController {
    var showToolbar = false

    class func instantiateFromStoryboard(url: NSURL) -> WebViewController {
        let webViewController = UIStoryboard.fulfillment().viewControllerWithID(.WebViewController) as WebViewController
        webViewController.URL = url
        return webViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = view as UIWebView
        webView.scalesPageToFit = true
        
        self.navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       self.navigationController?.setToolbarHidden(!showToolbar, animated: false)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setToolbarHidden(!showToolbar, animated: false)
    }
}
