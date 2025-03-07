import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!

    var photo: Photo? {
        didSet {
            guard isViewLoaded else { return }
            self.setupPhoto()
        }
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton() {
        guard let image = imageView.image else { return }
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

        self.setupPhoto()
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

extension SingleImageViewController {
    fileprivate func setupPhoto() {
        guard let photo = self.photo else {
            Logger.shared.error("нет фото")
            return
        }
        UIBlockingProgressHUD.show()
        self.imageView.kf.setImage(with: photo.largeImageURL) { [weak self] in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch $0 {
            case .success(let result):
                self.imageView.frame.size = result.image.size
                self.rescaleAndCenterImageInScrollView(image: result.image)
            case .failure(let error):
                Logger.shared.error(error.localizedDescription)
                self.showError()
            }
        }
    }

    fileprivate func showError() {
        let alert = UIAlertController(
            title: nil,
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Не надо", style: .cancel))
        alert.addAction(
            .init(title: "Повторить", style: .default) { [weak self] _ in
                self?.setupPhoto()
            })
        present(alert, animated: true)
    }

    fileprivate func updateContentInsets() {
        let ofsetX = (scrollView.contentSize.width - scrollView.bounds.size.width) / 2
        let ofsetY = (scrollView.contentSize.height - scrollView.bounds.size.height) / 2
        scrollView.contentInset = UIEdgeInsets(
            top: -ofsetY,
            left: -ofsetX,
            bottom: 0,
            right: 0
        )
    }

    fileprivate func rescaleAndCenterImageInScrollView(image: UIImage) {
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
