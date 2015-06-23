import Quick
import Nimble
import Kiosk

class SaleArtworkTests: QuickSpec {
    override func spec() {

        var saleArtwork: SaleArtwork!
        beforeEach {
            let artwork = Artwork.fromJSON([:]) as! Artwork
            saleArtwork = SaleArtwork(id: "id", artwork: artwork)
        }

        describe("estimates") {
            it("gives no estimtates when no estimates present") {
                expect(saleArtwork.estimateString) == "No Estimate"
            }
            
            it("gives estimtates when low and high are present") {
                saleArtwork.lowEstimateCents = 100_00
                saleArtwork.highEstimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $100–$200"
            }
            
            it("gives estimtates when low is present") {
                saleArtwork.lowEstimateCents = 100_00
                expect(saleArtwork.estimateString) == "Estimate: $100"
            }
            
            it("gives estimtates when high is present") {
                saleArtwork.highEstimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $200"
            }
        }

        describe("reserve status") {
            it("gives default number of bids") {
                let reserveStatus = saleArtwork.numberOfBidsWithReserveSignal.first() as! String

                expect(reserveStatus) == "0 bids placed"
            }

            describe("with some bids") { () -> Void in
                beforeEach {
                    saleArtwork.bidCount = 1
                }

                it("gives default number of bids") {
                    let reserveStatus = saleArtwork.numberOfBidsWithReserveSignal.first() as! String

                    expect(reserveStatus) == "1 bid placed"
                }

                it("updates reserve status when reserve status changes") {

                    var reserveStatus = ""
                    saleArtwork.numberOfBidsWithReserveSignal.subscribeNext { (newReserveStatus) -> Void in
                        reserveStatus = newReserveStatus as! String
                    }

                    saleArtwork.reserveStatus = ReserveStatus.ReserveNotMet.rawValue

                    expect(reserveStatus) == "(1 bid placed, Reserve not met)"
                }


                it("sends new status when reserve status changes") {
                    var invocations = 0
                    saleArtwork.numberOfBidsWithReserveSignal.subscribeNext { (newReserveStatus) -> Void in
                        invocations++
                    }
                    
                    saleArtwork.reserveStatus = ReserveStatus.ReserveNotMet.rawValue

                    // Once for initial subscription, another for update.
                    expect(invocations) == 2
                }

                it("updates reserve status when number of bids changes") {

                    var reserveStatus = ""
                    saleArtwork.numberOfBidsWithReserveSignal.subscribeNext { (newReserveStatus) -> Void in
                        reserveStatus = newReserveStatus as! String
                    }

                    saleArtwork.bidCount = 2

                    expect(reserveStatus) == "2 bids placed"
                }

                it("sends new status when number of bids changes") {
                    var invocations = 0
                    saleArtwork.numberOfBidsWithReserveSignal.subscribeNext { (newReserveStatus) -> Void in
                        invocations++
                    }

                    saleArtwork.bidCount = 2

                    // Once for initial subscription, another for update.
                    expect(invocations) == 2
                }

                it("sends new status when highest bid changes") {
                    var invocations = 0
                    saleArtwork.numberOfBidsWithReserveSignal.subscribeNext { (newReserveStatus) -> Void in
                        invocations++
                    }

                    saleArtwork.highestBidCents = 1_00

                    // Once for initial subscription, another for update.
                    expect(invocations) == 2
                }
            }
        }
    }
}
