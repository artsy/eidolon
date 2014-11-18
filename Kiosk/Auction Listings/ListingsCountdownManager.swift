import UIKit

class ListingsCountdownManager: NSObject {
   
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet var countdownContainerView: UIView!
    lazy var formatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()

    lazy var countdownManager: CountdownManager = {
        return CountdownManager.sharedInstance
    }()

    override func awakeFromNib() {
        let formatter = self.formatter

        countdownManager.saleIsActiveTickSignal().subscribeNext({ [weak self] (object) -> Void in
            let tuple = object as RACTuple
            let currentDate = tuple.first as NSDate
            let endDate = tuple.second as NSDate

            let flags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
            let components = NSCalendar.currentCalendar().components(flags, fromDate: currentDate, toDate: endDate, options: nil)

            self?.countdownLabel.text = "\(formatter.stringFromNumber(components.hour)!) : \(formatter.stringFromNumber(components.minute)!) : \(formatter.stringFromNumber(components.second)!)"
        }, completed: { [weak self] in
            self?.countdownLabel.text = "CLOSED"
            self?.hideDenomenatorLabels()
        })

        countdownManager.saleIsActiveTickSignal().take(1).subscribeNext { [weak self] (_) in
            self?.setLabelsHidden(false)
            return
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
}
