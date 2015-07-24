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

        it("updates the soldStatus") {
            let newArtwork = Artwork.fromJSON([:]) as! Artwork
            newArtwork.soldStatus = "sold"
            let newSaleArtwork = SaleArtwork(id: "id", artwork: newArtwork)

            saleArtwork.updateWithValues(newSaleArtwork)

            expect(newSaleArtwork.artwork.soldStatus) == "sold"
        }

        describe("estimates") {
            it("gives no estimtates when no estimates present") {
                expect(saleArtwork.estimateString) == "No Estimate"
            }
            
            it("gives estimtate range when low and high are present") {
                saleArtwork.lowEstimateCents = 100_00
                saleArtwork.highEstimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $100–$200"
            }

            it("gives estimate if present") {
                saleArtwork.estimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $200"
            }

            it("give estimate if estimate both and low/high are present") {
                saleArtwork.highEstimateCents = 300_00
                saleArtwork.lowEstimateCents = 100_00
                saleArtwork.estimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $200"
            }
            
            it("gives no estimate if only high is present") {
                saleArtwork.highEstimateCents = 100_00
                expect(saleArtwork.estimateString) == "No Estimate"
            }

            it("gives no estimate if only low is present") {
                saleArtwork.lowEstimateCents = 100_00
                expect(saleArtwork.estimateString) == "No Estimate"
            }

            it("indicates that an artwork is not for sale") {
                saleArtwork.artwork.soldStatus = "sold"
                expect((saleArtwork.forSaleSignal.first() as! Bool)).toEventually( beFalse() )
            }

            it("indicates that an artwork is for sale") {
                saleArtwork.artwork.soldStatus = "anything else"
                expect((saleArtwork.forSaleSignal.first() as! Bool)).toEventually( beTrue() )
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
