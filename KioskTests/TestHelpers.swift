import Foundation
import Quick
import Nimble
@testable
import Kiosk
import Moya

private enum DefaultsKeys: String {
    case TokenKey = "TokenKey"
    case TokenExpiry = "TokenExpiry"
}

func clearDefaultsKeys(defaults: NSUserDefaults) {
    defaults.removeObjectForKey(DefaultsKeys.TokenKey.rawValue)
    defaults.removeObjectForKey(DefaultsKeys.TokenExpiry.rawValue)
}

func getDefaultsKeys(defaults: NSUserDefaults) -> (key: String?, expiry: NSDate?) {
    let key = defaults.objectForKey(DefaultsKeys.TokenKey.rawValue) as! String?
    let expiry = defaults.objectForKey(DefaultsKeys.TokenExpiry.rawValue) as! NSDate?
    
    return (key: key, expiry: expiry)
}

func setDefaultsKeys(defaults: NSUserDefaults, key: String?, expiry: NSDate?) {
    defaults.setObject(key, forKey: DefaultsKeys.TokenKey.rawValue)
    defaults.setObject(expiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
}

func setupProviderForSuite(provider: ArtsyProvider<ArtsyAPI>) {
    beforeSuite {
        Provider.sharedProvider = provider
    }

    afterSuite {
        Provider.sharedProvider = Provider.DefaultProvider()
    }
}

func yearFromDate(date: NSDate) -> Int {
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    return calendar.components(.Year, fromDate: date).year
}

@objc class TestClass: NSObject { }

// Necessary since UIImage(named:) doesn't work correctly in the test bundle
extension UIImage {
    class func testImage(named name: String, ofType type: String) -> UIImage! {
        let bundle = NSBundle(forClass: TestClass().dynamicType)
        let path = bundle.pathForResource(name, ofType: type)
        return UIImage(contentsOfFile: path!)
    }
}

func testArtwork() -> Artwork {
    return Artwork.fromJSON(["id": "red",
    "title" : "Rose Red",
    "date": "June 11th 2014",
    "blurb": "Pretty good",
    "artist": ["id" : "artistDee", "name": "Dee Emm"],
    "images": [
        ["id" : "image_id",
        "image_url" : "http://example.com/:version.jpg",
        "image_versions" : ["large"],
        "aspect_ratio" : 1.508,
        "tile_base_url" : "http://example.com",
        "tile_size" : 1]
    ]]) as! Artwork
}

func testSaleArtwork() -> SaleArtwork {
    let saleArtwork = SaleArtwork(id: "12312313", artwork: testArtwork())
    saleArtwork.auctionID = "AUCTION"
    return saleArtwork
}

func testBidDetails() -> BidDetails {
    return BidDetails(saleArtwork: testSaleArtwork(), paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
}

class StubFulfillmentController: FulfillmentController {
    lazy var bidDetails: BidDetails = { () -> BidDetails in
        let bidDetails = BidDetails.stubbedBidDetails()
        bidDetails.setImage = { (_, imageView) -> () in
            imageView.image = loadingViewControllerTestImage
        }
        return bidDetails
        }()

    var auctionID: String! = ""
    var xAccessToken: String?
    var loggedInProvider: ReactiveCocoaMoyaProvider<ArtsyAPI>? = Provider.StubbingProvider()
    var loggedInOrDefaultProvider: ReactiveCocoaMoyaProvider<ArtsyAPI> = Provider.StubbingProvider()
}

/// Nimble is currently having issues with nondeterministic async expectations.
/// This will have to do for now 😢
/// See: https://github.com/Quick/Nimble/issues/177
func kioskWaitUntil(action: (() -> Void) -> Void) {
    waitUntil(timeout: 10, action: action)
}
