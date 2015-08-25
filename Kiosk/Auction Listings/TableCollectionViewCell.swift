import UIKit

class TableCollectionViewCell: ListingsCollectionViewCell {
    private lazy var infoView: UIView = {
        let view = UIView()
        view.addSubview(self.lotNumberLabel)
        view.addSubview(self.artistNameLabel)
        view.addSubview(self.artworkTitleLabel)

        self.lotNumberLabel.alignTop("0", bottom: nil, toView: view)
        self.lotNumberLabel.alignLeading("0", trailing: "0", toView: view)
        self.artistNameLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: self.lotNumberLabel, predicate: "5")
        self.artistNameLabel.alignLeading("0", trailing: "0", toView: view)
        self.artworkTitleLabel.alignLeading("0", trailing: "0", toView: view)
        self.artworkTitleLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: self.artistNameLabel, predicate: "0")
        self.artworkTitleLabel.alignTop(nil, bottom: "0", toView: view)
        return view
    }()

    private lazy var cellSubviews: [UIView] = [self.artworkImageView, self.infoView, self.currentBidLabel, self.numberOfBidsLabel, self.bidButton]
    
    override func setup() {
        super.setup()
        
        contentView.constrainWidth("\(TableCollectionViewCell.Width)")
        
        // Configure subviews
        numberOfBidsLabel.textAlignment = .Center
        artworkImageView.contentMode = .ScaleAspectFill
        artworkImageView.clipsToBounds = true
        
        // Add subviews
        cellSubviews.forEach{ self.contentView.addSubview($0) }
        
        // Constrain subviews
        artworkImageView.alignAttribute(.Width, toAttribute: .Height, ofView: artworkImageView, predicate: nil)
        artworkImageView.alignTop("14", leading: "0", bottom: "-14", trailing: nil, toView: contentView)
        artworkImageView.constrainHeight("56")

        infoView.alignAttribute(.Left, toAttribute: .Right, ofView: artworkImageView, predicate: "28")
        infoView.alignCenterYWithView(artworkImageView, predicate: "0")
        infoView.constrainWidth("300")

        currentBidLabel.alignAttribute(.Left, toAttribute: .Right, ofView: infoView, predicate: "33")
        currentBidLabel.alignCenterYWithView(artworkImageView, predicate: "0")
        currentBidLabel.constrainWidth("180")

        numberOfBidsLabel.alignAttribute(.Left, toAttribute: .Right, ofView: currentBidLabel, predicate: "33")
        numberOfBidsLabel.alignCenterYWithView(artworkImageView, predicate: "0")
        numberOfBidsLabel.alignAttribute(.Right, toAttribute: .Left, ofView: bidButton, predicate: "-33")
        
        bidButton.alignBottom(nil, trailing: "0", toView: contentView)
        bidButton.alignCenterYWithView(artworkImageView, predicate: "0")
        bidButton.constrainWidth("127")

        // Replaces the signal defined in the superclass, normally used to emit taps to a "More Info" label, which we don't have.
        let recognizer = UITapGestureRecognizer()
        contentView.addGestureRecognizer(recognizer)
        self.moreInfoSignal = recognizer.rac_gestureSignal()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.drawBottomSolidBorderWithColor(UIColor.artsyMediumGrey())
    }
}

extension TableCollectionViewCell {
    private struct SharedDimensions {
        var width: CGFloat = 0
        var height: CGFloat = 84
        
        static var instance = SharedDimensions()
    }
    
    class var Width: CGFloat {
        get {
            return SharedDimensions.instance.width
        }
        set (newWidth) {
            SharedDimensions.instance.width = newWidth
        }
    }
    
    class var Height: CGFloat {
        return SharedDimensions.instance.height
    }
}
