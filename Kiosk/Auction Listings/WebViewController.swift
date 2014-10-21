class WebViewController: DZNWebViewController {
    var showToolbar = false

    convenience init(url: NSURL) {
        self.init()
        self.URL = url
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSizeMake(815, 660)
        navigationController?.view.layer.cornerRadius = 0;

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
