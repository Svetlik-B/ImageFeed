import Foundation
import XCTest

@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var gotUrlExpectation = XCTestExpectation(description: "got URL")
    var isViewLoadedChecked = XCTestExpectation(description: "isViewLoaded checked")
    var dismissCalled = false
    var imageURL: URL?
    var presenter: ProfileViewPresenterProtocol?
    var _isViewLoaded: Bool = true
    var isViewLoaded: Bool {
        get {
            isViewLoadedChecked.fulfill()
            return _isViewLoaded
        }
        set {
            _isViewLoaded = newValue;
        }
    }
    
    func updateAvatar(_ url: URL) {
        imageURL = url
        gotUrlExpectation.fulfill()
    }
    func updateProfileDetails(profile: ImageFeed.ProfileService.Profile) {}
    func dismiss() { dismissCalled = true }
}
