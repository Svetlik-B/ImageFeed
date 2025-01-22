import Foundation
import UIKit

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
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        navigationController?.popViewController(animated: true)
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                self?.tokenStorage.token = token
            case .failure(let error):
                print(error)
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
