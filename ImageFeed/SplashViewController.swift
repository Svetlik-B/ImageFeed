import ProgressHUD
import UIKit

final class SplashViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YP Black")
        let screenLogo = UIImageView()
        screenLogo.image = UIImage(named: "Logo_of_Unsplash")
        view.addSubview(screenLogo)

        screenLogo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            screenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
        } else {
            let authViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "AuthViewController")
            let navigationController = UINavigationController(
                rootViewController: authViewController
            )
            if let authViewController = authViewController as? AuthViewController {
                authViewController.delegate = self
            } else {
                Logger.shared.error("не найден контроллер авторизации")
            }
            (authViewController as? AuthViewController)?.delegate = self
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: false)
        }
    }
}
// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: false)
    }
}

// MARK: - Implementation
extension SplashViewController {
    private enum Constants {
        static let authorizeSegueIdentifier = "Authorize"
        static let gallerySegueIdentifier = "Gallery"
    }
    private func fetchProfile(token: String) {
        ProgressHUD.animate(interaction: false)
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            ProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared
                    .fetchProfileImageURL(username: profile.username) { result in
                        if case .failure(let failure) = result {
                            Logger.shared.error(failure.localizedDescription)
                        }
                    }
                self.switchToTabBarController()

            case .failure(let error):
                Logger.shared.error(error.localizedDescription)
            }
        }
    }
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: false)
    }
}
