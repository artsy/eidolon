class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var url: NSURL?

    class func instantiateFromStoryboard(url: NSURL) -> WebViewController {
        let webViewController = UIStoryboard.fulfillment().viewControllerWithID(.WebViewController) as WebViewController
        webViewController.url = url
        return webViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
}
