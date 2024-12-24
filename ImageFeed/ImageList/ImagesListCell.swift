import UIKit

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var gradientView: UIView!
    private(set) var gradient: CAGradientLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.gradient = CAGradientLayer()
        self.gradient.frame = self.gradientView.bounds
        self.gradient.colors = [
            UIColor(named: "YP Black 0")!.cgColor,
            UIColor(named: "YP Black 20")!.cgColor,
        ]
        self.gradientView.layer.insertSublayer(self.gradient, at: 0)
    }
}
