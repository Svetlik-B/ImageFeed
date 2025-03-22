import Foundation

protocol ImageListViewPresenterProtocol {
    var photos: [Photo] { get }
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    )
    func fetchPhotosNextPage()
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    init (view: ImageListViewControllerProtocol) {
        self.view = view
        addObserver()
    }
    deinit {
        removeObserver()
    }
    var photos: [Photo] = []
    var imagesListService: ImagesListServiceProtocol? {
        didSet {
            imagesListService?.fetchPhotosNextPage()
        }
    }
    private weak var view: ImageListViewControllerProtocol?
}

extension ImageListViewPresenter {
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        imagesListService?.changeLike(
            photoId: photoId,
            isLike: isLike
        ) { result in
            switch result {
            case .success:
                self.toggleIsLiked(for: photoId)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func fetchPhotosNextPage() {
        imagesListService?.fetchPhotosNextPage()
    }
}

// MARK: Implementation
extension ImageListViewPresenter {
    func toggleIsLiked(for photoId: String) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[keyPath: \.[index].isLiked].toggle()
        }
    }
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    @objc func updateTableViewAnimated() {
        guard let imagesListService
        else {
            return
        }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
