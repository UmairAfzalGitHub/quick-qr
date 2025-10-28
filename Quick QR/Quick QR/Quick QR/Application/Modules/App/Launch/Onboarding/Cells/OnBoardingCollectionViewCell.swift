
import UIKit

class OnBoardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(data: OnBoarding) {
        contentImageView.image = data.topImage
        headingLabel.text = data.heading
        descriptionLabel.text = data.description
        if UIDevice().isSmallDevice {
            imageBottomConstraint.constant = 2
        } else if UIDevice().isProDevice() {
            imageBottomConstraint.constant = 6
        }
    }
    
    class func cellForCollectionView(collectionView: UICollectionView, indexPath: IndexPath) -> OnBoardingCollectionViewCell {
        let kOnBoardingCollectionViewCellIdentifier = "kOnBoardingCollectionViewCellIdentifier"
        collectionView.register(UINib(nibName: "OnBoardingCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: kOnBoardingCollectionViewCellIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kOnBoardingCollectionViewCellIdentifier, for: indexPath) as! OnBoardingCollectionViewCell
        return cell
    }
}
