import Quick
import Nimble
import RxSwift
@testable
import Kiosk

class KeypadViewModelTestClass: NSObject {
    // Start with invalid data
    var stringValue = Variable("something invalid")
    var intValue = Variable(-1)
}

class KeypadViewModelTests: QuickSpec {
    override func spec() {
        var subject: KeypadViewModel!
        var testHarness: KeypadViewModelTestClass!
        var disposeBag: DisposeBag!
        
        beforeEach {
            subject = KeypadViewModel()
            testHarness = KeypadViewModelTestClass()
            disposeBag = DisposeBag()

            subject
                .stringValue
                .bindTo(testHarness.stringValue)
                .addDisposableTo(disposeBag)
            subject
                .intValue
                .bindTo(testHarness.intValue)
                .addDisposableTo(disposeBag)
        }
        
        it("it has default values") {
            expect(testHarness.intValue) == 0
            expect(testHarness.stringValue) == ""
        }
        
        it("adds digits") {
            waitUntil { done in
                [1,3,3,7]
                    .reduce(empty(), combine: { (signal, input) -> Observable<Void> in
                        signal.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribeCompleted { () -> Void in
                        expect(testHarness.intValue) == 1337
                        expect(testHarness.stringValue) == "1337"

                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

        }

        it("has a max int, but not max string, value") {
            waitUntil { done in

                [1,3,3,3,3,3,3,3,3,3,3,3,7]
                    .reduce(empty(), combine: { (signal, input) -> Observable<Void> in
                        signal.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribeCompleted { () -> Void in
                        expect(testHarness.intValue) == 1333333
                        expect(testHarness.stringValue) == "1333333333337"

                        done()
                    }
                    .addDisposableTo(disposeBag)
            }
        }
        
        it("handles prepended zeros") {
            waitUntil { done in
                [0,1,3,3,7]
                    .reduce(empty(), combine: { (signal, input) -> Observable<Void> in
                        signal.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribeCompleted { () -> Void in
                        expect(testHarness.intValue) == 1337
                        expect(testHarness.stringValue) == "01337"
                        
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }
        }
        
        it("clears") {
            waitUntil { done in
                empty()
                    .then {
                        subject.addDigitAction.execute(1).map(void)
                    }
                    .then {
                        subject.clearAction.execute()
                    }
                    .subscribeCompleted { () -> Void in // TODO: project-wide find/replace to get rid of this.
                        expect(testHarness.intValue) == 0
                        expect(testHarness.stringValue) == ""
                        
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }
        }
        
        it("deletes") {
            waitUntil { done in
                [1,3,3]
                    .reduce(empty(), combine: { (signal, input) -> Observable<Void> in
                        signal.then { subject.addDigitAction.execute(input) }
                    })
                    .then {
                        subject.deleteAction.execute()
                    }.subscribeCompleted { () -> Void in
                        expect(testHarness.intValue) == 13
                        expect(testHarness.stringValue) == "13"

                        done()
                    }
                    .addDisposableTo(disposeBag)
            }
        }
    }
}
