import Foundation

protocol ImageListViewPresenterProtocol {
    var photos: [Photo] { get }
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    )
    func toggleIsLiked(for photoId: String)
    func fetchPhotosNextPage()
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    init (view: ImageListViewControllerProtocol, imagesListService: ImagesListService) {
        self.view = view
        self.imagesListService = imagesListService
        imagesListService.fetchPhotosNextPage()
        addObserver()
    }
    deinit {
        removeObserver()
    }
    private(set) var photos: [Photo] = []
    private weak var view: ImageListViewControllerProtocol?
    private let imagesListService: ImagesListService
}

extension ImageListViewPresenter {
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        imagesListService.changeLike(
            photoId: photoId,
            isLike: isLike,
            completion
        )
    }
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    func toggleIsLiked(for photoId: String) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[keyPath: \.[index].isLiked].toggle()
        }
    }
}

// MARK: Implementation

extension ImageListViewPresenter {
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
    @objc fileprivate func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
