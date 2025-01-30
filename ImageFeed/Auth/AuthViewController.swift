import Foundation
import UIKit
import ProgressHUD

private let showWebViewSegueIdentifier = "ShowWebView"

final class AuthViewController: UIViewController {
    var tokenStorage = OAuth2TokenStorage()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            if let vc = segue.destination as? WebViewViewController {
                vc.delegate = self
            }
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    enum Constant {
        static let gallerySegueIdentifier = "Gallery"
    }
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        ProgressHUD.animate()
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let token):
                self?.tokenStorage.token = token
                self?.performSegue(withIdentifier: Constant.gallerySegueIdentifier, sender: nil)
            case .failure(let error):
                self?.navigationController?.popViewController(animated: true)
                print(error)
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
