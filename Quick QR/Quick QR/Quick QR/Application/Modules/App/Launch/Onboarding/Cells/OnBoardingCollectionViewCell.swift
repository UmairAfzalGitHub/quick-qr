
import UIKit

class OnBoardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(data: OnBoarding) {
        contentImageView.image = data.topImage
        headingLabel.text = data.heading
        descriptionLabel.text = data.description
    }
    
    class func cellForCollectionView(collectionView: UICollectionView, indexPath: IndexPath) -> OnBoardingCollectionViewCell {
        let kOnBoardingCollectionViewCellIdentifier = "kOnBoardingCollectionViewCellIdentifier"
        collectionView.register(UINib(nibName: "OnBoardingCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: kOnBoardingCollectionViewCellIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kOnBoardingCollectionViewCellIdentifier, for: indexPath) as! OnBoardingCollectionViewCell
        return cell
    }
}
