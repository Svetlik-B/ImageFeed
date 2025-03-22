import XCTest

@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testViewControllerDismissOnLogout() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(view: viewController)
        viewController.presenter = presenter
        
        // when
        presenter.logout()
        
        // then
        XCTAssertTrue(viewController.dismissCalled)
    }
    func testReceiveProfileDataAfterViewDidLoad() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(view: viewController)
        viewController.presenter = presenter
        viewController.isViewLoaded = true
        
        // when
        let url = URL(string: "https://example.com/image.jpg")!
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self,
            userInfo: ["URL": url]
        )
        
        // then
        wait(
            for: [viewController.gotUrlExpectation, viewController.isViewLoadedChecked],
            timeout: 0.1
        )
        XCTAssertEqual(viewController.imageURL, url)
    }
    func testReceiveProfileDataBeforeViewDidLoad() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(view: viewController)
        viewController.presenter = presenter
        viewController.isViewLoaded = false
        
        // when
        let url = URL(string: "https://example.com/image.jpg")!
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self,
            userInfo: ["URL": url]
        )
        
        // then
        wait(for: [viewController.isViewLoadedChecked], timeout: 0.1)
    }
}
