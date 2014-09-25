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
                time.sync()
                expect(time.inSync()) == true
            }

            it("returns a date in the future") {
                let time = SystemTime()
                time.sync()

                let currentYear = yearFromDate(NSDate())
                let timeYear = yearFromDate(time.date())

                expect(timeYear) > currentYear
                expect(timeYear) == 2422
            }

            it("creates a new date each sync") {
                let time = SystemTime()
                time.sync()

                let oldDate = time.date()
                time.sync()

                expect(oldDate.timeIntervalSince1970) < time.date().timeIntervalSince1970
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

func yearFromDate(date: NSDate) -> Int {
    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
    return calendar.components(.CalendarUnitYear, fromDate: date).year
}