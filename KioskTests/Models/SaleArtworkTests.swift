import Quick
import Nimble
import RxNimble
@testable
import Kiosk
import RxSwift
import RxBlocking

class SaleArtworkTests: QuickSpec {
    override func spec() {

        var saleArtwork: SaleArtwork!
        var disposeBag: DisposeBag!

        beforeEach {
            let artwork = Artwork.fromJSON([:])
            saleArtwork = SaleArtwork(id: "id", artwork: artwork, currencySymbol: "£")
            disposeBag = DisposeBag()
        }

        it("updates the soldStatus") {
            let newArtwork = Artwork.fromJSON([:])
            newArtwork.soldStatus = true
            let newSaleArtwork = SaleArtwork(id: "id", artwork: newArtwork, currencySymbol: "£")

            saleArtwork.updateWithValues(newSaleArtwork)

            expect(newSaleArtwork.artwork.soldStatus) == true
        }

        describe("estimates") {
            it("gives no estimtates when no estimates present") {
                expect(saleArtwork.viewModel.estimateString) == ""
            }
            
            it("gives estimtate range when low and high are present") {
                saleArtwork.lowEstimateCents = 100_00
                saleArtwork.highEstimateCents = 200_00
                expect(saleArtwork.viewModel.estimateString) == "Estimate: £100–£200"
            }

            it("gives estimate if present") {
                saleArtwork.estimateCents = 200_00
                expect(saleArtwork.viewModel.estimateString) == "Estimate: £200"
            }

            it("give estimate if estimate both and low/high are present") {
                saleArtwork.highEstimateCents = 300_00
                saleArtwork.lowEstimateCents = 100_00
                saleArtwork.estimateCents = 200_00
                expect(saleArtwork.viewModel.estimateString) == "Estimate: £200"
            }
            
            it("gives no estimate if only high is present") {
                saleArtwork.highEstimateCents = 100_00
                expect(saleArtwork.viewModel.estimateString) == ""
            }

            it("gives no estimate if only low is present") {
                saleArtwork.lowEstimateCents = 100_00
                expect(saleArtwork.viewModel.estimateString) == ""
            }

            it("indicates that an artwork is not for sale") {
                saleArtwork.artwork.soldStatus = true
                expect(try! saleArtwork.viewModel.forSale().toBlocking().first()) == false
            }

            it("indicates that an artwork is for sale") {
                saleArtwork.artwork.soldStatus = false
                expect(try! saleArtwork.viewModel.forSale().toBlocking().first()) == true
            }
        }

        describe("reserve status") {
            it("gives default number of bids as an empty string") {
                // highest bid, reserve status, and number of bids
                expect(saleArtwork.viewModel.numberOfBidsWithReserve) == ""
            }

            describe("with some bids") {
                beforeEach {
                    saleArtwork.bidCount = 1
                }

                it("gives default number of bids") {
                    expect(saleArtwork.viewModel.numberOfBidsWithReserve) == "1 bid placed"
                }

                it("updates reserve status when reserve status changes") {

                    var reserveStatus = ""
                    saleArtwork.reserveStatus = ReserveStatus.ReserveNotMet.rawValue

                    saleArtwork.viewModel.numberOfBidsWithReserve.subscribe(onNext: { (newReserveStatus) in
                        reserveStatus = newReserveStatus
                    }).addDisposableTo(disposeBag)

                    expect(reserveStatus) == "(1 bid placed, Reserve not met)"
                }


                it("sends new status when reserve status changes") {
                    var invocations = 0
                    saleArtwork.viewModel.numberOfBidsWithReserve.subscribe(onNext: { (newReserveStatus) in
                        invocations += 1
                    }).addDisposableTo(disposeBag)
                    
                    saleArtwork.reserveStatus = ReserveStatus.ReserveNotMet.rawValue

                    // Once for initial subscription, another for update.
                    expect(invocations) == 2
                }

                it("updates reserve status when number of bids changes") {

                    var reserveStatus = ""
                    saleArtwork.viewModel.numberOfBidsWithReserve.subscribe(onNext: { (newReserveStatus) in
                        reserveStatus = newReserveStatus
                    }).addDisposableTo(disposeBag)

                    saleArtwork.bidCount = 2

                    expect(reserveStatus) == "2 bids placed"
                }

                it("sends new status when number of bids changes") {
                    var invocations = 0
                    saleArtwork.viewModel.numberOfBidsWithReserve.subscribe(onNext: { (newReserveStatus) in
                        invocations += 1
                    }).addDisposableTo(disposeBag)

                    saleArtwork.bidCount = 2

                    // Once for initial subscription, another for update.
                    expect(invocations) == 2
                }

                it("sends new status when highest bid changes") {
                    var invocations = 0
                    saleArtwork.viewModel.numberOfBidsWithReserve.subscribe(onNext: { (newReserveStatus) in
                        invocations += 1
                    }).addDisposableTo(disposeBag)

                    saleArtwork.highestBidCents = 1_00

                    // Once for initial subscription, another for update.
                    expect(invocations) == 2
                }
            }
        }
    }
}
