import Quick
import Nimble
import RxNimble
@testable
import Kiosk

class RegistrationCoordinatorTests: QuickSpec {
    override func spec() {
        var sale: Sale!
        var bidDetails: BidDetails!
        var subject: RegistrationCoordinator!
        
        beforeEach {
            bidDetails = testBidDetails()
            bidDetails.newUser = NewUser()
            sale = makeSale()
            subject = RegistrationCoordinator()
            subject.storyboard = fulfillmentStoryboard
            subject.sale = sale
        }

        describe("nextViewControllerForBidDetails") {
            it("defaults to the mobile VC") {
                let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                expect(vc).to( beAKindOf(RegistrationMobileViewController.self) )
            }

            it("moves onto email after mobile") {
                bidDetails.newUser.phoneNumber.value = "5555555555"
                let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                expect(vc).to( beAKindOf(RegistrationEmailViewController.self) )
            }

            it("moves onto password if there is no PIN") {
                bidDetails.newUser.phoneNumber.value = "5555555555"
                bidDetails.newUser.email.value = "test@example.com"
                bidDetails.bidderPIN.value = nil
                let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                expect(vc).to( beAKindOf(RegistrationPasswordViewController.self) )
            }

            describe("with CC swipe enabled") {
                it("moves onto credit card after email") {
                    AppSetup.sharedState.disableCardReader = false
                    bidDetails.newUser.phoneNumber.value = "5555555555"
                    bidDetails.newUser.email.value = "test@example.com"
                    bidDetails.newUser.password.value = "password"
                    let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                    expect(vc).to( beAKindOf(SwipeCreditCardViewController.self) )
                }
            }

            describe("with CC swipe disabled") {
                it("moves onto manual credit card input after email") {
                    AppSetup.sharedState.disableCardReader = true
                    bidDetails.newUser.phoneNumber.value = "5555555555"
                    bidDetails.newUser.email.value = "test@example.com"
                    bidDetails.newUser.password.value = "password"
                    let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                    expect(vc).to( beAKindOf(ManualCreditCardInputViewController.self) )
                }
            }

            it("confirms after all data is entered") {
                bidDetails.newUser.phoneNumber.value = "5555555555"
                bidDetails.newUser.email.value = "test@example.com"
                bidDetails.newUser.password.value = "password"
                bidDetails.newUser.creditCardToken.value = "abcdefg123456"
                let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                expect(vc).to( beAKindOf(UIViewController.self) )
            }

            it("sets the new index on the coordinator") {
                bidDetails.newUser.phoneNumber.value = "5555555555"
                _ = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                expect(subject.currentIndex).first == RegistrationIndex.emailVC
            }

            describe("with swipeless sale") {
                beforeEach {
                    sale = makeSale(bypassCreditCardRequirement: true)
                }

                it("defaults to the name VC") {
                    let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                    expect(vc).to( beAKindOf(RegistrationNameViewController.self) )
                }

                it("moves onto the mobile after name") {
                    bidDetails.newUser.name.value = "Fname Lname"
                    let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                    expect(vc).to( beAKindOf(RegistrationMobileViewController.self) )
                }

                it("skips credit card sipe") {
                    bidDetails.newUser.phoneNumber.value = "5555555555"
                    bidDetails.newUser.email.value = "test@example.com"
                    bidDetails.newUser.password.value = "password"
                    let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                    expect(vc).notTo( beAKindOf(SwipeCreditCardViewController.self) )
                }

                it("confirms after all data is entered") {
                    bidDetails.newUser.phoneNumber.value = "5555555555"
                    bidDetails.newUser.email.value = "test@example.com"
                    bidDetails.newUser.password.value = "password"
                    let vc = subject.nextViewControllerForBidDetails(bidDetails, sale: sale)
                    expect(vc).to( beAKindOf(UIViewController.self) )
                }
            }
        }
    }
}
