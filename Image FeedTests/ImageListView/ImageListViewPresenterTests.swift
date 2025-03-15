import XCTest

@testable import ImageFeed

final class ImageListViewPresenterTests: XCTestCase {
    func test_constructor() {
        // given
        let imageListServiceSpy = ImagesListServiceSpy()
        let viewSpy = ImagesListViewControllerSpy()
        
        // when
        let presenter = ImageListViewPresenter(
            view: viewSpy,
            imagesListService: imageListServiceSpy
        )
        wait(for: [viewSpy.expectation])
        
        // then
        XCTAssertEqual(imageListServiceSpy.fetchPhotosNextPageCount, 1)
        XCTAssertEqual(presenter.photos.count, imageListServiceSpy.photos.count)
        XCTAssertEqual(viewSpy.oldCount, 0)
        XCTAssertEqual(viewSpy.newCount, 2)
    }
    func test_fetchPhotosNextPage() {
        // given
        let imageListServiceSpy = ImagesListServiceSpy()
        let presenter = ImageListViewPresenter(
            view: ImagesListViewControllerSpy(),
            imagesListService: imageListServiceSpy
        )
        XCTAssertEqual(imageListServiceSpy.fetchPhotosNextPageCount, 1)
        
        // when
        presenter.fetchPhotosNextPage()
        
        // then
        XCTAssertEqual(imageListServiceSpy.fetchPhotosNextPageCount, 2)
    }
    func test_toggleIsLiked() {
        // given
        let viewSpy = ImagesListViewControllerSpy()
        let imageListServiceSpy = ImagesListServiceSpy()
        let presenter = ImageListViewPresenter(
            view: viewSpy,
            imagesListService: imageListServiceSpy
        )
        wait(for: [viewSpy.expectation])
        XCTAssertTrue(presenter.photos[1].isLiked)
        
        // when
        presenter.toggleIsLiked(for: "2")
        
        // then
        XCTAssertFalse(presenter.photos[1].isLiked)
    }
}

final class ImagesListViewControllerSpy: ImageListViewControllerProtocol {
    let expectation = XCTestExpectation(description: "updateTableViewAnimated called")
    var oldCount: Int?
    var newCount: Int?
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        self.oldCount = oldCount
        self.newCount = newCount
        expectation.fulfill()
    }
}

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var fetchPhotosNextPageCount = 0
    var changeLikeIsCalled = false
    var photos: [ImageFeed.Photo] = [
        .init(
            id: "1",
            size: .zero,
            thumbImageURL: URL(string: "https://example.com/thumb1.jpg")!,
            largeImageURL: URL(string: "https://example.com/large1.jpg")!,
            isLiked: false
        ),
        .init(
            id: "2",
            size: .zero,
            thumbImageURL: URL(string: "https://example.com/thumb2.jpg")!,
            largeImageURL: URL(string: "https://example.com/large2.jpg")!,
            isLiked: true
        ),
    ]
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCount += 1
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        changeLikeIsCalled = true
    }
    
    
}
