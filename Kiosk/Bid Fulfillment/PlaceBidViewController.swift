import UIKit

public class PlaceBidViewController: UIViewController {

    public class func instantiateFromStoryboard() -> PlaceBidViewController {
        return  UIStoryboard(name: "Fulfillment", bundle: nil)
                .instantiateViewControllerWithIdentifier("PlaceBidViewController") as PlaceBidViewController
    }    

}
