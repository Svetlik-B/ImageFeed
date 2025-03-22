import Foundation

@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?

    func viewDidLoad() { viewDidLoadCalled = true }
    func logout() {}
}
