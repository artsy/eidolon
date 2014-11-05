import UIKit

class ListingsCountdownManager: NSObject {
   
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet var countdownContainerView: UIView!
    let formatter = NSNumberFormatter()

    dynamic var sale: Sale?

    let time = SystemTime()
    
    override func awakeFromNib() {
        formatter.minimumIntegerDigits = 2

        time.syncSignal().subscribeNext { [weak self] (_) in
            self?.startTimer()
            self?.setLabelsHidden(false)
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
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        self.tick(timer)
    }
    
    func tick(timer: NSTimer) {
        if let sale = sale {
            if time.inSync() == false { return }
            if sale.id == "" { return }

            if sale.isActive(time) {
                let now = time.date()
                let flags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
                let components = NSCalendar.currentCalendar().components(flags, fromDate: now, toDate: sale.endDate, options: nil)
                
                self.countdownLabel.text = "\(formatter.stringFromNumber(components.hour)!) : \(formatter.stringFromNumber(components.minute)!) : \(formatter.stringFromNumber(components.second)!)"

            } else {
                self.countdownLabel.text = "CLOSED"
                hideDenomenatorLabels()
                timer.invalidate()
            }

        }
    }
}
