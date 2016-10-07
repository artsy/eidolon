import Quick
import Nimble
import Nimble_Snapshots
import RxSwift
@testable
import Kiosk

class HelpViewControllerConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a help view controller") { (sharedExampleContext: @escaping SharedExampleContext) in
            var subject: HelpViewController!
            
            beforeEach {
                subject = sharedExampleContext()["subject"] as! HelpViewController!
            }
            
            it("looks correct") {
                expect(subject) == snapshot()
                return
            }
        }
    }
}


class HelpViewControllerTests: QuickSpec {
    override func spec() {
        var subject: HelpViewController!
        
        beforeEach {
            subject = HelpViewController()
            // Default to no buyers premium
            subject.hasBuyersPremium = Observable.just(false).take(1)
        }
        
        itBehavesLike("a help view controller") { ["subject": subject] }
        
        describe("with a buyers premium") {
            beforeEach {
                subject.hasBuyersPremium = Observable.just(true).take(1)
            }
            
            itBehavesLike("a help view controller") { ["subject": subject] }
        }
    }
}
