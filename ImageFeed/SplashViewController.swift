import UIKit

final class SplashViewController: UIViewController {
    enum Constants {
        static let authorizeSegueIdentifier = "Authorize"
        static let gallerySegueIdentifier = "Gallery"
    }
    let tokenStorage = OAuth2TokenStorage()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tokenStorage.token = nil
        if self.tokenStorage.token != nil {
            performSegue(
                withIdentifier: Constants.gallerySegueIdentifier,
                sender: nil
            )
        } else {
            performSegue(
                withIdentifier: Constants.authorizeSegueIdentifier,
                sender: nil
            )
        }
    }
}

