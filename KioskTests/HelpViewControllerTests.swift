import Quick
import Nimble
import Nimble_Snapshots
import ReactiveCocoa
@testable
import Kiosk

class HelpViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a help view controller") { (sharedExampleContext: SharedExampleContext) in
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
            subject.hasBuyersPremiumSignal = RACSignal.`return`(false).take(1)
        }
        
        itBehavesLike("a help view controller") { ["subject": subject] }
        
        describe("with a buyers premium") {
            beforeEach {
                subject.hasBuyersPremiumSignal = RACSignal.`return`(true).take(1)
            }
            
            itBehavesLike("a help view controller") { ["subject": subject] }
        }
    }
}