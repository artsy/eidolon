import Quick
import Nimble
import RxNimble
import RxSwift
import RxCocoa
@testable
import Kiosk

class KeypadViewModelTestClass: NSObject {
    // Start with invalid data
    var _string = ""
    lazy var stringValue: Binder<String> = {
        return Binder<String>(self, binding: { (target, text) in
            target._string = text
            return
        })
    }()
    var _currency = UInt64(0)
    lazy var currencyValue: Binder<UInt64> = {
        Binder<UInt64>(self, binding: { (target, currency) in
            target._currency = currency
            return
        })
    }()
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
            expect(testHarness._currency) == 0
            expect(testHarness._string) == ""
        }
        
        it("adds digits") {
            waitUntil { done in
                [1,3,3,7]
                    .reduce(Observable.empty(), { (observable, input) -> Observable<Void> in
                        observable.then { subject.addDigitAction.execute(input) }
                    })
                    .subscribe(onCompleted: {
                        expect(testHarness._currency) == 1337
                        expect(testHarness._string) == "1337"

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
                        expect(testHarness._currency) == 1333333
                        expect(testHarness._string) == "1333333333337"

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
                        expect(testHarness._currency) == 1337
                        expect(testHarness._string) == "01337"
                        
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
                        expect(testHarness._currency) == 0
                        expect(testHarness._string) == ""
                        
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
                        expect(testHarness._currency) == 13
                        expect(testHarness._string) == "13"

                        done()
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
}
