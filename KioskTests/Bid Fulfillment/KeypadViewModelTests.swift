import Quick
import Nimble
import RxNimble
import RxSwift
@testable
import Kiosk

class KeypadViewModelTestClass: NSObject {
    // Start with invalid data
    var stringValue = Variable("something invalid")
    var currencyValue = Variable<Currency>(0)
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
                .asObservable()
                .bindTo(testHarness.stringValue)
                .addDisposableTo(disposeBag)
            subject
                .currencyValue
                .asObservable()
                .bindTo(testHarness.currencyValue)
                .addDisposableTo(disposeBag)
        }
        
        it("it has default values") {
            expect(testHarness.currencyValue) == 0
            expect(testHarness.stringValue) == ""
        }
        
        it("adds digits") {
            waitUntil { done in
                [1,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue) == 1337
                        expect(testHarness.stringValue) == "1337"

                        done()
                    })
                    .addDisposableTo(disposeBag)
            }

        }

        it("has a max int, but not max string, value") {
            waitUntil { done in

                [1,3,3,3,3,3,3,3,3,3,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue) == 1333333
                        expect(testHarness.stringValue) == "1333333333337"

                        done()
                    })
                    .addDisposableTo(disposeBag)
            }
        }
        
        it("handles prepended zeros") {
            waitUntil { done in
                [0,1,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue) == 1337
                        expect(testHarness.stringValue) == "01337"
                        
                        done()
                    })
                    .addDisposableTo(disposeBag)
            }
        }
        
        it("clears") {
            waitUntil { done in
                Observable.empty()
                    .then {
                        subject.addDigitAction.execute(1).map(void)
                    }
                    .then {
                        subject.clearAction.execute()
                    }
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue) == 0
                        expect(testHarness.stringValue) == ""
                        
                        done()
                    })
                    .addDisposableTo(disposeBag)
            }
        }
        
        it("deletes") {
            waitUntil { done in
                [1,3,3]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .then {
                        subject.deleteAction.execute()
                    }.subscribe(onCompleted: {
                        expect(testHarness.currencyValue) == 13
                        expect(testHarness.stringValue) == "13"

                        done()
                    })
                    .addDisposableTo(disposeBag)
            }
        }
    }
}
