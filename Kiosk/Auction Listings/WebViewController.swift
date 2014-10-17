class WebViewController: DZNWebViewController {

    class func instantiateFromStoryboard(url: NSURL) -> WebViewController {
        let webViewController = UIStoryboard.fulfillment().viewControllerWithID(.WebViewController) as WebViewController
        webViewController.URL = url
        return webViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = view as UIWebView
        webView.scalesPageToFit = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.toolbarHidden = true
    }
}
