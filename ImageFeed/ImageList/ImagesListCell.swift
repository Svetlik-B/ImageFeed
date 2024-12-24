import UIKit

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.likeButton.setTitle("", for: .normal)
        self.likeButton.setImage(UIImage(named: "Heart Red"), for: .normal)
        self.likeButton.layer.borderWidth = 2
        self.likeButton.layer.borderColor = UIColor.red.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
