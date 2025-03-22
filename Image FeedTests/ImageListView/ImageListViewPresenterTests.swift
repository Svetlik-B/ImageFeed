import XCTest

@testable import ImageFeed

final class ImageListViewPresenterTests: XCTestCase {
    func test_setImageListService() {
        // given
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImageListViewPresenter(view: viewSpy)
        let imageListServiceSpy = ImagesListServiceSpy()
        imageListServiceSpy.presenter = presenter
        // when

        presenter.imagesListService = imageListServiceSpy
        
        // then
        XCTAssertEqual(imageListServiceSpy.fetchPhotosNextPageCount, 1)
        XCTAssertEqual(viewSpy.oldCount, 0)
        XCTAssertEqual(viewSpy.newCount, 10)
    }
    func test_fetchPhotosNextPage() {
        // given
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImageListViewPresenter(view: viewSpy)
        let imageListServiceSpy = ImagesListServiceSpy()
        imageListServiceSpy.presenter = presenter
        presenter.imagesListService = imageListServiceSpy
        XCTAssertEqual(imageListServiceSpy.fetchPhotosNextPageCount, 1)
        XCTAssertEqual(viewSpy.newCount, 10)

        // when
        presenter.fetchPhotosNextPage()

        // then
        XCTAssertEqual(imageListServiceSpy.fetchPhotosNextPageCount, 2)
        XCTAssertEqual(viewSpy.oldCount, 10)
        XCTAssertEqual(viewSpy.newCount, 20)
    }
    func test_changeLike() {
        // given
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImageListViewPresenter(view: viewSpy)
        let imageListServiceSpy = ImagesListServiceSpy()
        imageListServiceSpy.presenter = presenter
        presenter.imagesListService = imageListServiceSpy

        XCTAssertFalse(presenter.photos[3].isLiked)

        // when
        presenter.changeLike(photoId: "3", isLike: true) { _ in  }

        // then
        XCTAssertTrue(imageListServiceSpy.changeLikeIsCalled)
        XCTAssertTrue(presenter.photos[3].isLiked)
    }
    func test_toggleIsLiked() {
        // given
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImageListViewPresenter(view: viewSpy)
        let imageListServiceSpy = ImagesListServiceSpy()
        imageListServiceSpy.presenter = presenter
        presenter.imagesListService = imageListServiceSpy

        XCTAssertFalse(presenter.photos[9].isLiked)

        // when
        presenter.toggleIsLiked(for: "9")

        // then
        XCTAssertTrue(presenter.photos[9].isLiked)
    }
}

final class ImagesListViewControllerSpy: ImageListViewControllerProtocol {
    var oldCount: Int?
    var newCount: Int?
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        self.oldCount = oldCount
        self.newCount = newCount
    }
}

func mockPhoto(id: String) -> ImageFeed.Photo {
    .init(
        id: id,
        size: .zero,
        thumbImageURL: URL(string: "https://example.com/thumb1.jpg")!,
        largeImageURL: URL(string: "https://example.com/large1.jpg")!,
        isLiked: false
    )
}

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var fetchPhotosNextPageCount = 0
    var changeLikeIsCalled = false
    var photos = [ImageFeed.Photo]()
    var presenter: ImageListViewPresenter?

    func fetchPhotosNextPage() {
        photos.append(
            contentsOf: (photos.count ..< photos.count + 10)
                .map(String.init)
                .map(mockPhoto)
        )
        fetchPhotosNextPageCount += 1
        presenter?.updateTableViewAnimated()
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        changeLikeIsCalled = true
        completion(.success(()))
    }

}
