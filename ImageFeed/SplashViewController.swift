import ProgressHUD
import UIKit

final class SplashViewController: UIViewController {
    let tokenStorage = OAuth2TokenStorage()
    let profileService = ProfileService()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tokenStorage.token = nil
//    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = self.tokenStorage.token {
            fetchProfile(token: token)
        } else {
            performSegue(
                withIdentifier: Constants.authorizeSegueIdentifier,
                sender: nil
            )
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.authorizeSegueIdentifier {
            if let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first
                    as? AuthViewController
            {
                authViewController.delegate = self
            } else {
                Logger.error("не найден контроллер авторизации")
            }
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
        profileService.fetchProfile(token) { [weak self] result in
            ProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success:
                self.switchToTabBarController()

            case .failure(let error):
                Logger.error(error.localizedDescription)
            }
        }
    }
    private func switchToTabBarController() {
        performSegue(
            withIdentifier: Constants.gallerySegueIdentifier,
            sender: nil
        )
    }
}
