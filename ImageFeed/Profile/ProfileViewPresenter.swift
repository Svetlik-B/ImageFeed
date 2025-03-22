import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    init(view: ProfileViewControllerProtocol) {
        self.view = view
        addObserver()
    }

    deinit {
        removeObserver()
    }

    func viewDidLoad() {
        if let avatarURL = ProfileImageService.shared.imageURL {
            view?.updateAvatar(avatarURL)
        }
        if let profile = ProfileService.shared.profile {
            view?.updateProfileDetails(profile: profile)
        }
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
        view?.dismiss()
    }
}

// MARK: - Implementation
extension ProfileViewPresenter {
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    @objc fileprivate func updateAvatar(notification: Notification) {
        guard
            view?.isViewLoaded == true,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? URL
        else { return }
        DispatchQueue.main.async { [weak self] in
            self?.view?.updateAvatar(profileImageURL)
        }
    }
}
