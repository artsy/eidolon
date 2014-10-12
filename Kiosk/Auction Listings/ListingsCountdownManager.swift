import UIKit

class ListingsCountdownManager: NSObject {
   
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet var countdownContainerView: UIView!

    dynamic var targetDate: NSDate?

    let time = SystemTime()
    
    override func awakeFromNib() {
        
        time.syncSignal().subscribeNext { [weak self] (_) -> Void in
            self?.setLabelsHidden(false)
            self?.startTimer()
        }
    }
    
    func setLabelsHidden(hidden: Bool) {
        countdownContainerView.hidden = hidden
    }

    func hideDenomenatorLabels() {
        for subview in countdownContainerView.subviews as [UIView] {
            subview.hidden = subview != countdownLabel
        }
    }

    
    func startTimer() {
        let timer = NSTimer(timeInterval: 0.49, target: self, selector: "tick:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        self.tick(timer)
    }
    
    func tick(timer: NSTimer) {
        if let targetDate = targetDate {

            let now = time.date()
            
            if now.laterDate(targetDate) == now {
                self.countdownLabel.text = "CLOSED"
                hideDenomenatorLabels()
                timer.invalidate()
                
            } else {
                let flags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
                let components = NSCalendar.currentCalendar().components(flags, fromDate: now, toDate: targetDate, options: nil)
                
                self.countdownLabel.text = "\(components.day) \(components.hour) \(components.second)"
            }

        }
    }
}
