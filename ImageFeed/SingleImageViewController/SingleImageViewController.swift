import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            self.imageView.image = image
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}
