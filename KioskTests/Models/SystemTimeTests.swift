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

        beforeEach {
            disposeBag = DisposeBag()
        }

        describe("in sync") {
            setupProviderForSuite(Provider.StubbingProvider())

            it("returns true") {
                let time = SystemTime()
                time
                    .syncSignal()
                    .subscribeNext { (_) in
                        expect(time.inSync()) == true
                        return
                    }
                    .addDisposableTo(disposeBag)
            }

            it("returns a date in the future") {
                let time = SystemTime()
                time
                    .syncSignal()
                    .subscribeNext { (_) in
                        let currentYear = yearFromDate(NSDate())
                        let timeYear = yearFromDate(time.date())

                        expect(timeYear) > currentYear
                        expect(timeYear) == 2422

                    }
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
                let currentYear = yearFromDate(NSDate())
                let timeYear = yearFromDate(time.date())

                expect(timeYear) == currentYear
            }
        }
    }
}
