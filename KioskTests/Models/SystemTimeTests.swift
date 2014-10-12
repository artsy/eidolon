import Quick
import Nimble

// Note, stubbed json contains a date in 2422
// If this is an issue ( hello future people! ) then move it along a few centuries.

class SystemTimeTests: QuickSpec {
    override func spec() {

        describe("in sync") {
            setupProviderForSuite(Provider.StubbingProvider())

            it("returns true") {
                let time = SystemTime()
                time.syncSignal().subscribeNext { (_) -> Void in
                    expect(time.inSync()) == true
                    return
                }
            }

            it("returns a date in the future") {
                let time = SystemTime()
                time.syncSignal().subscribeNext { (_) -> Void in
                    let currentYear = yearFromDate(NSDate())
                    let timeYear = yearFromDate(time.date())

                    expect(timeYear) > currentYear
                    expect(timeYear) == 2422

                }
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
