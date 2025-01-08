import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            self.setupImage(image)
        }
    }
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton() {
        guard let image else { return }
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
}

// MARK: - override

extension SingleImageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.1
        self.scrollView.maximumZoomScale = 1.25
        
        self.setupImage(image)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInsets()
    }
}

// MARK: - implementation

private extension SingleImageViewController {
    func setupImage(_ image: UIImage?) {
        self.imageView.image = self.image
        self.imageView.frame.size = self.image?.size ?? .zero
        guard let image = self.image else { return }
        self.rescaleAndCenterImageInScrollView(image: image)
    }
    func updateContentInsets() {
        let ofsetX = (scrollView.contentSize.width - scrollView.bounds.size.width) / 2
        let ofsetY = (scrollView.contentSize.height - scrollView.bounds.size.height) / 2
        scrollView.contentInset = UIEdgeInsets(
            top: -ofsetY,
            left: -ofsetX,
            bottom: 0,
            right: 0
        )
    }
    
    func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        let horizontalScale = scrollView.bounds.size.width / image.size.width
        let verticalScale = scrollView.bounds.size.height / image.size.height
        var scale = min(horizontalScale, verticalScale)
        scale = max(scale, scrollView.minimumZoomScale)
        scale = min(scale, scrollView.maximumZoomScale)
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        updateContentInsets()
    }
}
