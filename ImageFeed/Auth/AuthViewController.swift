import Foundation
import ProgressHUD
import UIKit

private let showWebViewSegueIdentifier = "ShowWebView"

protocol AuthViewControllerDelegate: NSObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    var delegate: AuthViewControllerDelegate?
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
        ProgressHUD.animate(interaction: false)
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                ProgressHUD.dismiss()
                Logger.error(error.localizedDescription)
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
