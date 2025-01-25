import UIKit

final class SplashViewController: UIViewController {
    private enum Constants {
        static let authorizeSegueIdentifier = "Authorize"
        static let gallerySegueIdentifier = "Gallery"
    }
    let tokenStorage = OAuth2TokenStorage()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

