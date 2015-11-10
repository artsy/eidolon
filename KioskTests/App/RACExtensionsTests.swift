import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import UIKit

class RACExtensionsTests: QuickSpec {
    override func spec() {
        describe("viewWillDisappearSignal") {
            it("sends when viewWillDisappear: is called") {
                var sent = false

                let subject = UIViewController()
                waitUntil{ (done) -> Void in
                    subject.viewWillDisappearSignal().subscribeNext { _ -> Void in
                        sent = true
                        done()
                    }

                    subject.viewWillDisappear(false)
                }

                expect(sent) == true
            }
        }
    }
}