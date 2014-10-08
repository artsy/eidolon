import UIKit

class TableCollectionViewCell: ListingsCollectionViewCell {
    private lazy var infoView: UIView = {
        let view = UIView()
        view.addSubview(self.artistNameLabel)
        view.addSubview(self.artworkTitleLabel)
        
        self.artistNameLabel.alignTop("0", bottom: nil, toView: view)
        self.artistNameLabel.alignLeading("0", trailing: "0", toView: view)
        self.artworkTitleLabel.alignLeading("0", trailing: "0", toView: view)
        self.artworkTitleLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: self.artistNameLabel, predicate: "0")
        self.artworkTitleLabel.alignTop(nil, bottom: "", toView: view)
        return view
    }()
    
    private lazy var cellSubviews: [UIView] = [self.artworkImageView, self.infoView, self.dividerView, self.currentBidLabel, self.numberOfBidsLabel, self.bidButton]
    
    override func setup() {
        super.setup()
        
        // Configure subviews
        numberOfBidsLabel.textAlignment = .Center
        artworkImageView.contentMode = .ScaleAspectFill
        artworkImageView.clipsToBounds = true
        
        // Add subivews
        cellSubviews.map{ self.contentView.addSubview($0) }
        
        // Constrain subviews
        artworkImageView.constrainHeightToView(contentView, predicate: "-28")
        artworkImageView.alignAttribute(.Width, toAttribute: .Height, ofView: artworkImageView, predicate: nil)
        artworkImageView.alignTop("14", leading: "0", bottom: nil, trailing: nil, toView: contentView)
        infoView.alignAttribute(.Left, toAttribute: .Right, ofView: artworkImageView, predicate: "28")
        infoView.alignCenterYWithView(artworkImageView, predicate: "0")
        infoView.constrainWidth("184")
        currentBidLabel.constrainLeadingSpaceToView(infoView, predicate: "33")
        currentBidLabel.alignCenterYWithView(artworkImageView, predicate: "0")
        currentBidLabel.constrainWidth("304")
        numberOfBidsLabel.constrainLeadingSpaceToView(currentBidLabel, predicate: "33")
        numberOfBidsLabel.alignCenterYWithView(artworkImageView, predicate: "0")
        numberOfBidsLabel.alignAttribute(.Right, toAttribute: .Left, ofView: bidButton, predicate: "-33")
        
        bidButton.alignBottom(nil, trailing: "0", toView: contentView)
        bidButton.alignCenterYWithView(contentView, predicate: "0")
        bidButton.constrainWidth("127")
        dividerView.constrainHeight("1")
        dividerView.alignTop(nil, leading: "0", bottom: "0", trailing: "0", toView: contentView)
    }
}
