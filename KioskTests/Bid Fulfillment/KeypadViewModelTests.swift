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
                .bind(to: testHarness.stringValue)
                .disposed(by: disposeBag)
            subject
                .currencyValue
                .asObservable()
                .bind(to: testHarness.currencyValue)
                .disposed(by: disposeBag)
        }
        
        it("it has default values") {
            expect(testHarness.currencyValue.asObservable()).first == 0
            expect(testHarness.stringValue.asObservable()).first == ""
        }
        
        it("adds digits") {
            waitUntil { done in
                [1,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue.asObservable()).first == 1337
                        expect(testHarness.stringValue.asObservable()).first == "1337"

                        done()
                    })
                    .disposed(by: disposeBag)
            }

        }

        it("has a max int, but not max string, value") {
            waitUntil { done in

                [1,3,3,3,3,3,3,3,3,3,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue.asObservable()).first == 1333333
                        expect(testHarness.stringValue.asObservable()).first == "1333333333337"

                        done()
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        it("handles prepended zeros") {
            waitUntil { done in
                [0,1,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue.asObservable()).first == 1337
                        expect(testHarness.stringValue.asObservable()).first == "01337"
                        
                        done()
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        it("clears") {
            waitUntil { done in
                Observable.empty()
                    .then {
                        subject.addDigitAction.execute(1).map(void)
                    }
                    .then {
                        subject.clearAction.execute(Void())
                    }
                    .subscribe(onCompleted: {
                        expect(testHarness.currencyValue.asObservable()).first == 0
                        expect(testHarness.stringValue.asObservable()).first == ""
                        
                        done()
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        it("deletes") {
            waitUntil { done in
                [1,3,3]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .then {
                        subject.deleteAction.execute(Void())
                    }.subscribe(onCompleted: {
                        expect(testHarness.currencyValue.asObservable()).first == 13
                        expect(testHarness.stringValue.asObservable()).first == "13"

                        done()
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
}
