import Quick
import Nimble
@testable
import Kiosk
import RxSwift

// Note, stubbed json contains a date in 2422
// If this is an issue ( hello future people! ) then move it along a few centuries.

class SystemTimeTests: QuickSpec {
    override func spec() {

        var disposeBag: DisposeBag!
        var networking: Networking!

        beforeEach {
            networking = Networking.newStubbingNetworking()
            disposeBag = DisposeBag()
        }

        describe("in sync") {

            it("returns true") {
                let time = SystemTime()
                time
                    .sync(networking)
                    .subscribe(onNext: { (_) in
                        expect(time.inSync()) == true
                        return
                    })
                    .addDisposableTo(disposeBag)
            }

            it("returns a date in the future") {
                let time = SystemTime()
                time
                    .sync(networking)
                    .subscribe(onNext: { (_) in
                        let currentYear = yearFromDate(Date())
                        let timeYear = yearFromDate(time.date())

                        expect(timeYear) > currentYear
                        expect(timeYear) == 2422

                    })
                    .addDisposableTo(disposeBag)
            }
        }

        describe("not in sync") {
            it("returns false") {
                let time = SystemTime()
                expect(time.inSync()) == false
            }

            it("returns current time") {
                let time = SystemTime()
                let currentYear = yearFromDate(Date())
                let timeYear = yearFromDate(time.date())

                expect(timeYear) == currentYear
            }
        }
    }
}
