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
        self.gradient.colors = [Constant.black0, Constant.black20]
        self.gradientView.layer.insertSublayer(self.gradient, at: 0)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.kf.cancelDownloadTask()
    }
}

private enum Constant {
    static var black0: CGColor {
        assert(UIColor(named: "YP Black 0") != nil, "Не определён цвет 'YP Black 0'")
        guard let color = UIColor(named: "YP Black 0")?.cgColor
        else {
            Logger.shared.error("не определён цвет 'YP Black 0'")
            return UIColor.clear.cgColor
        }
        return color
    }
    static var black20: CGColor {
        assert(UIColor(named: "YP Black 0") != nil, "Не определён цвет 'YP Black 20'")
        guard let color = UIColor(named: "YP Black 20")?.cgColor
        else {
            Logger.shared.error("не определён цвет 'YP Black 20'")
            return UIColor(white: 0, alpha: 20).cgColor
        }
        return color
    }
}
