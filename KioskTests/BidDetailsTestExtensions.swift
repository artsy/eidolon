import Foundation

extension BidDetails {

    class func stubbedBidDetails() -> BidDetails {

        let artistDict = ["id" : "artistDee", "name": "Dee Emm"]
        let data:[String: AnyObject] =  ["id": "red", "title" : "Rose Red", "date": "June 11th 2014", "blurb": "Pretty good", "artist":artistDict]
        let artwork = Artwork.fromJSON(data) as Artwork

        let saleArtwork = SaleArtwork(id: "12312313", artwork: artwork)
        return BidDetails(saleArtwork: saleArtwork, paddleNumber: "1111", bidderPIN: "2222", bidAmountCents: 123456)
    }

}