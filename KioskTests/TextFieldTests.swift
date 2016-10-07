import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots

class TextFieldTests: QuickSpec {
    override func spec() {

        pending("TextField") {
            var textField: TextField?
            beforeEach {
                let window = UIWindow(frame:UIScreen.main.bounds)
                let vc = UIViewController()
                textField = TextField(frame: CGRect(x: 0, y: 0, width: 255, height: 44))
                textField!.shouldAnimateStateChange = false
                vc.view.addSubview(textField!)
                window.rootViewController = vc
                window.makeKeyAndVisible()
                textField!.becomeFirstResponder()
                textField!.text = "Text text"
            }

            it("looks correct when not in focus") {
                textField!.resignFirstResponder()
                expect(textField!).to(haveValidSnapshot(named:"not in focus"))
            }

            it("looks correct when in focus") {
                expect(textField!).to(haveValidSnapshot(named:"in focus"))
            }
        }

        pending("SecureTextField") {
            var textField: SecureTextField?
            beforeEach {
                let window = UIWindow(frame:UIScreen.main.bounds)
                let vc = UIViewController()
                textField = SecureTextField(frame: CGRect(x: 0, y: 0, width: 255, height: 44))
                textField!.shouldAnimateStateChange = false
                textField!.text = ""
                textField!.font = UIFont.serifFont(withSize: textField!.font!.pointSize)
                vc.view.addSubview(textField!)
                window.rootViewController = vc
                window.makeKeyAndVisible()
                textField!.becomeFirstResponder()
                textField!.insertText("Secure")
            }

            describe("in focus") {
                it("looks correct") {
                    expect(textField!).to(haveValidSnapshot(named:"in focus"))
                }

                it("stores text") {
                    expect(textField!.text).to(equal("Secure"))
                    expect(textField!.actualText).to(equal("Secure"))
                }
            }


            describe("not in focus") {
                beforeEach {
                    textField!.resignFirstResponder()
                    return
                }

                it("looks correct") {
                    expect(textField!).to(haveValidSnapshot(named:"not in focus"))
                }

                it("stores text") {
                    expect(textField!.text).to(equal("Secure"))
                    expect(textField!.actualText).to(equal("Secure"))
                }
            }

            describe("editing a second time") {
                beforeEach {
                    textField!.resignFirstResponder()
                    textField!.becomeFirstResponder()
                }

                it("looks correct") {
                    expect(textField!).to(haveValidSnapshot(named:"second edit"))
                }

                it("clears stored text") {
                    expect(textField!.text).to(equal(""))
                    expect(textField!.actualText).to(equal(""))
                }
            }
        }
    }
}
