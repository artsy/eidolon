import UIKit

class CursorView: UIView {

    let cursorLayer: CALayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        setupCursorLayer()
        startAnimating()
    }

    func setup() {
        layer.addSublayer(cursorLayer)
        setupCursorLayer()
    }

    func setupCursorLayer() {
        cursorLayer.frame = CGRectMake(CGRectGetWidth(layer.frame)/2 - 1, 0, 2, CGRectGetHeight(layer.frame))
        cursorLayer.backgroundColor = UIColor.blackColor().CGColor
        cursorLayer.opacity = 0.0
    }

    func startAnimating() {
        animate(Float.infinity)
    }

    private func animate(times: Float) {
        let fade = CABasicAnimation()
        fade.duration = 0.5
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fade.repeatCount = times
        fade.autoreverses = true
        fade.fromValue = 0.0
        fade.toValue = 1.0
        cursorLayer.addAnimation(fade, forKey: "opacity")
    }

    func stopAnimating() {
        cursorLayer.removeAllAnimations()
    }
}
