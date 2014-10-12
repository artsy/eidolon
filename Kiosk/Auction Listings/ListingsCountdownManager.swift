import UIKit

class ListingsCountdownManager: NSObject {
   
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet var timeDenomenatorViews: [UILabel]!
    dynamic var targetDate: NSDate?

    let time = SystemTime()
    
    override func awakeFromNib() {
        self.setLabelsHidden(true)
        
        time.syncSignal().subscribeNext { [weak self] (_) -> Void in
            self?.setLabelsHidden(false)
            self?.startTimer()
        }
    }
    
    func setLabelsHidden(hidden: Bool) {
//        for label in timeDenomenatorViews as [UILabel] {
//            label.hidden = hidden
//        }
//        self.countdownLabel.hidden = hidden
    }
    
    func startTimer() {
        let timer = NSTimer(timeInterval: 1, target: self, selector: "tick", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        self.tick()
    }
    
    func tick() {
        if let targetDate = targetDate {

            let now = time.date()
            if now.laterDate(targetDate) == now {
                self.countdownLabel.text = "CLOSED"
                
            } else {
                let flags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
                let components = NSCalendar.currentCalendar().components(flags, fromDate: now, toDate: targetDate, options: nil)
                
                self.countdownLabel.text = "\(components.day) \(components.hour) \(components.second)"
            }

        }
    }
}
