import Quick
import Nimble

class TextFieldTests: QuickSpec {
    override func spec() {
        it("looks correct when not in focus") {
            let window = UIWindow(frame:UIScreen.mainScreen().bounds)
            let vc = UIViewController()
            let textField = UITextField(frame: CGRectMake(0, 0, 300, 20))
//            textField.shouldAnimateStateChange = false
            textField.text = "Text text"
            vc.view.addSubview(textField)
            window.rootViewController = vc
            window.makeKeyAndVisible()
            expect(textField).to(recordSnapshot(named:"not in focus"))
        }

        it("looks correct when in focus") {
            let window = UIWindow(frame:UIScreen.mainScreen().bounds)
            let vc = UIViewController()
            let textField = UITextField(frame: CGRectMake(0, 0, 300, 20))
//            textField.shouldAnimateStateChange = false
            textField.text = "Text text"
            vc.view.addSubview(textField)
            window.rootViewController = vc
            window.makeKeyAndVisible()
            textField.becomeFirstResponder()

            expect(textField).to(recordSnapshot(named:"in focus"))
            expect(textField.text).to(equal("Text text"))
        }
    }
}
