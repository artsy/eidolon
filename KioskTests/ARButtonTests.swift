import Quick
import Nimble

class ARButtonTests: QuickSpec {
    override func spec() {
        it("looks correct in various states") {

            let buttonFrame = CGRectMake(0, 0, 120, 50);
            let view = UIView(frame: CGRectMake(0, 0, 600, 180))
            let button1 = Button(frame:buttonFrame)
            button1.setTitle("1 - default", forState: UIControlState.Normal)

            // If the button is green, we're good.
            
            let button2 = Button(frame:buttonFrame)
            button2.normalBGColor = UIColor.greenColor()
            button2.normalBorderColor = UIColor.redColor()
            button2.center = CGPointMake(200, 25)
            button2.setTitle("2 - colors", forState: UIControlState.Normal)
            button2.stateChangedAnimated(false)

            let button3 = Button(frame:buttonFrame)
            button3.highlightBGColor = UIColor.greenColor()
            button3.highlightBorderColor = UIColor.redColor()
            button3.center = CGPointMake(340, 25)
            button3.setTitle("3 - hlight", forState: UIControlState.Highlighted)
            button3.highlighted = true
            
            let button4 = Button(frame:buttonFrame)
            button4.disabledBGColor = UIColor.greenColor()
            button4.disabledBorderColor = UIColor.redColor()
            button4.center = CGPointMake(60, 100)
            button4.setTitle("4 - disabled", forState: UIControlState.Disabled)
            button4.enabled = false
            
            let button5 = Button(frame:buttonFrame)
            button5.selectedBGColor = UIColor.greenColor()
            button5.selectedBorderColor = UIColor.redColor()
            button5.center = CGPointMake(200, 100)
            button5.setTitle("5 - selected", forState: UIControlState.Selected)
            button5.selected = true

            for button in [button1, button2, button3, button4, button5] {
                view.addSubview(button);
            }
            
            expect(view).to(haveValidSnapshot(named:"default"))
            
        }
    }
}
